import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": Deno.env.get("ALLOWED_ORIGIN") ?? "null",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-cron-secret",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const cronSecret = Deno.env.get("PLATFORM_CRON_SECRET");
  const headerSecret = req.headers.get("x-cron-secret");
  if (!cronSecret || headerSecret !== cronSecret) {
    return new Response("Unauthorized", { status: 401 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  const now = new Date().toISOString();
  const { data: connections, error } = await supabase
    .from("platform_connections")
    .select("user_id, platform")
    .eq("status", "connected")
    .lte("next_scheduled_sync_at", now);

  if (error) return new Response(error.message, { status: 500 });

  let triggered = 0;
  for (const conn of connections ?? []) {
    const response = await fetch(
      `${Deno.env.get("SUPABASE_URL")}/functions/v1/platform-sync`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
          "x-sync-user-id": conn.user_id,
        },
        body: JSON.stringify({
          platform: conn.platform,
          lookback_days: 7,
          trigger_source: "cron",
        }),
      },
    );
    if (response.ok) triggered += 1;

    await supabase.from("platform_connections").update({
      next_scheduled_sync_at: new Date(Date.now() + 24 * 3600 * 1000).toISOString(),
    }).eq("user_id", conn.user_id).eq("platform", conn.platform);
  }

  return new Response(JSON.stringify({ triggered, checked: connections?.length ?? 0 }), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
