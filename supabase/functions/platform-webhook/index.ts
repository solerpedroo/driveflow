import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": Deno.env.get("ALLOWED_ORIGIN") ?? "null",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-webhook-secret",
};

const PLATFORMS = new Set(["uber", "99", "indrive"]);

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 });

  const secret = Deno.env.get("PLATFORM_WEBHOOK_SECRET");
  if (!secret || req.headers.get("x-webhook-secret") !== secret) {
    return new Response("Unauthorized", { status: 401 });
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "JSON inválido" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const platform = (body.platform as string)?.toLowerCase();
  const externalUserId = body.external_user_id as string;
  const eventType = body.event_type as string;

  if (!platform || !PLATFORMS.has(platform) || !externalUserId) {
    return new Response(JSON.stringify({ error: "Payload inválido" }), { status: 400 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  const { data: connection } = await supabase
    .from("platform_connections")
    .select("user_id")
    .eq("platform", platform)
    .eq("external_account_id", externalUserId)
    .maybeSingle();

  if (!connection) {
    return new Response(JSON.stringify({ error: "Conexão não encontrada" }), { status: 404 });
  }

  // Dispara sync sob demanda para payout/trip events
  if (eventType === "trip.completed" || eventType === "payout.credited") {
    await fetch(`${Deno.env.get("SUPABASE_URL")}/functions/v1/platform-sync`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
        "x-sync-user-id": connection.user_id,
      },
      body: JSON.stringify({
        platform,
        lookback_days: 3,
        trigger_source: "webhook",
      }),
    });
  }

  return new Response(JSON.stringify({ ok: true, event: eventType }), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
