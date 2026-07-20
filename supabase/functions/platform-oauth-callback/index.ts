import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { exchangeAuthorizationCode } from "../_shared/platform_oauth.ts";
import {
  opaqueOAuthErrorCode,
  validateAppRedirectUri,
} from "../_shared/security_utils.ts";
import { storeConnectionOAuth } from "../_shared/platform_secrets.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": Deno.env.get("ALLOWED_ORIGIN") ?? "null",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function redirectToApp(uri: string, params: Record<string, string>) {
  const url = new URL(uri);
  for (const [k, v] of Object.entries(params)) url.searchParams.set(k, v);
  return Response.redirect(url.toString(), 302);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const url = new URL(req.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  const error = url.searchParams.get("error");
  const errorDescription = url.searchParams.get("error_description");

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  if (!state) return new Response("state ausente", { status: 400 });

  const { data: oauthState, error: stateError } = await supabase
    .from("platform_oauth_states")
    .select("*")
    .eq("state_token", state)
    .maybeSingle();

  if (stateError || !oauthState) {
    return new Response("Estado OAuth inválido", { status: 400 });
  }

  const appRedirectUri = oauthState.redirect_uri as string;
  const platform = oauthState.platform as string;
  const expiresAt = new Date(oauthState.expires_at as string);

  if (!validateAppRedirectUri(appRedirectUri)) {
    return new Response("redirect_uri inválido", { status: 400 });
  }

  if (Number.isNaN(expiresAt.getTime()) || expiresAt.getTime() < Date.now()) {
    await supabase.from("platform_oauth_states").delete().eq("id", oauthState.id);
    return redirectToApp(appRedirectUri, {
      status: "error",
      platform,
      error: "expired",
    });
  }

  if (error) {
    const message = errorDescription ?? error;
    await supabase.from("platform_connections").update({
      status: "error",
      last_sync_error: message,
    }).eq("user_id", oauthState.user_id).eq("platform", platform);

    await supabase.from("platform_oauth_states").delete().eq("id", oauthState.id);

    return redirectToApp(appRedirectUri, {
      status: "error",
      platform,
      error: opaqueOAuthErrorCode(error, errorDescription),
    });
  }

  if (!code) return new Response("code ausente", { status: 400 });

  try {
    const tokenPayload = await exchangeAuthorizationCode(
      platform,
      code,
      oauthState.code_verifier as string | undefined,
    );

    const { data: profile } = await supabase
      .from("platform_connections")
      .select("metadata")
      .eq("user_id", oauthState.user_id)
      .eq("platform", platform)
      .maybeSingle();

    let externalAccountId = `acct_${platform}`;
    if (platform === "uber") {
      try {
        const meResponse = await fetch("https://api.uber.com/v1/partners/me", {
          headers: { Authorization: `Bearer ${tokenPayload.access_token}` },
        });
        if (meResponse.ok) {
          const me = await meResponse.json() as { driver_id?: string };
          if (me.driver_id) externalAccountId = me.driver_id;
        }
      } catch {
        // Perfil opcional — conexão segue com id genérico.
      }
    }

    const baseMetadata = {
      ...(profile?.metadata as Record<string, unknown> | null ?? {}),
    };
    delete baseMetadata.oauth;

    const { data: connectionRow, error: upsertError } = await supabase
      .from("platform_connections")
      .upsert({
        user_id: oauthState.user_id,
        platform,
        status: "connected",
        external_account_id: externalAccountId,
        metadata: baseMetadata,
        last_sync_error: null,
        next_scheduled_sync_at: new Date(Date.now() + 24 * 3600 * 1000).toISOString(),
      }, { onConflict: "user_id,platform" })
      .select("id")
      .single();

    if (upsertError || !connectionRow?.id) {
      throw new Error(upsertError?.message ?? "Falha ao salvar conexão.");
    }

    await storeConnectionOAuth(supabase, {
      connectionId: connectionRow.id,
      userId: oauthState.user_id as string,
      oauth: tokenPayload,
      metadata: baseMetadata,
    });

    await supabase.from("platform_oauth_states").delete().eq("id", oauthState.id);

    return redirectToApp(appRedirectUri, {
      status: "connected",
      platform,
    });
  } catch (exchangeError) {
    const message = exchangeError instanceof Error
      ? exchangeError.message
      : "Falha ao concluir autorização.";
    console.error("platform-oauth-callback exchange failed:", message);

    await supabase.from("platform_connections").update({
      status: "error",
      last_sync_error: message,
    }).eq("user_id", oauthState.user_id).eq("platform", platform);

    await supabase.from("platform_oauth_states").delete().eq("id", oauthState.id);

    return redirectToApp(appRedirectUri, {
      status: "error",
      platform,
      error: "oauth_failed",
    });
  }
});
