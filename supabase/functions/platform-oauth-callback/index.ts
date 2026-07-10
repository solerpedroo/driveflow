import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

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
  const expiresAt = new Date(oauthState.expires_at as string);

  if (Number.isNaN(expiresAt.getTime()) || expiresAt.getTime() < Date.now()) {
    await supabase.from("platform_oauth_states").delete().eq("id", oauthState.id);
    return new Response("Estado OAuth expirado", { status: 400 });
  }

  if (error) {
    await supabase.from("platform_connections").update({
      status: "error",
      last_sync_error: error,
    }).eq("user_id", oauthState.user_id).eq("platform", oauthState.platform);

    return redirectToApp(appRedirectUri, { status: "error", message: error });
  }

  if (!code) return new Response("code ausente", { status: 400 });

  // TODO: trocar code por tokens com API da plataforma
  const tokenPayload = {
    access_token: `stub_${oauthState.platform}_${Date.now()}`,
    refresh_token: `refresh_${oauthState.platform}`,
    expires_at: new Date(Date.now() + 3600 * 1000).toISOString(),
  };

  await supabase.from("platform_connections").upsert({
    user_id: oauthState.user_id,
    platform: oauthState.platform,
    status: "connected",
    external_account_id: `acct_${oauthState.platform}`,
    metadata: { oauth: tokenPayload },
    last_sync_error: null,
    next_scheduled_sync_at: new Date(Date.now() + 24 * 3600 * 1000).toISOString(),
  }, { onConflict: "user_id,platform" });

  await supabase.from("platform_oauth_states").delete().eq("id", oauthState.id);

  return redirectToApp(appRedirectUri, {
    status: "connected",
    platform: oauthState.platform as string,
  });
});
