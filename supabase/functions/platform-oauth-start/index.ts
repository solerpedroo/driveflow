import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import {
  getClientCredentials,
  getPlatformDefinition,
  oauthCallbackUri,
  platformNotConfiguredMessage,
} from "../_shared/platform_config.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": Deno.env.get("ALLOWED_ORIGIN") ?? "null",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const PLATFORMS = new Set(["uber", "99", "indrive"]);

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Método não suportado" }, 405);

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "Não autenticado" }, 401);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: "Sessão inválida" }, 401);

  let body: { platform?: string; redirect_uri?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "JSON inválido" }, 400);
  }

  const platform = (body.platform as string)?.toLowerCase();
  const appRedirectUri = body.redirect_uri as string;

  if (!platform || !PLATFORMS.has(platform)) {
    return json({ error: "Plataforma inválida" }, 400);
  }
  if (!appRedirectUri) return json({ error: "redirect_uri obrigatório" }, 400);

  const definition = getPlatformDefinition(platform);
  if (!definition) {
    return json({ error: platformNotConfiguredMessage(platform) }, 503);
  }

  const credentials = getClientCredentials(definition);
  if (!credentials) {
    return json({ error: platformNotConfiguredMessage(platform) }, 503);
  }

  const stateToken = crypto.randomUUID();
  const expiresAt = new Date(Date.now() + 15 * 60 * 1000).toISOString();

  const { error: stateError } = await supabase.from("platform_oauth_states").insert({
    user_id: userData.user.id,
    platform,
    state_token: stateToken,
    redirect_uri: appRedirectUri,
    expires_at: expiresAt,
  });

  if (stateError) return json({ error: stateError.message }, 500);

  const authUrl = new URL(definition.authorizeUrl);
  authUrl.searchParams.set("client_id", credentials.clientId);
  authUrl.searchParams.set("response_type", "code");
  authUrl.searchParams.set("redirect_uri", oauthCallbackUri());
  authUrl.searchParams.set("state", stateToken);
  authUrl.searchParams.set("scope", definition.scopes.join(" "));

  await supabase.from("platform_connections").upsert({
    user_id: userData.user.id,
    platform,
    status: "pending",
    last_sync_error: null,
  }, { onConflict: "user_id,platform" });

  return json({
    authorization_url: authUrl.toString(),
    state_token: stateToken,
    expires_at: expiresAt,
  });
});
