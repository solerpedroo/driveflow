import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const allowedOrigin = Deno.env.get("ALLOWED_ORIGIN") ?? "";

const corsHeaders = {
  "Access-Control-Allow-Origin": allowedOrigin || "null",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const INTEGRATABLE_PLATFORMS = new Set(["uber", "99", "indrive"]);

type SyncEarningRow = {
  external_id: string;
  amount: number;
  rides: number;
  worked_hours: number;
  date: string;
  note?: string;
};

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function clientError(message: string, status = 400) {
  return jsonResponse({ error: message }, status);
}

/**
 * Stub de sincronização — contrato pronto para adapters Uber/99/InDrive.
 * Quando credenciais OAuth estiverem configuradas, cada adapter retorna
 * SyncEarningRow[] que são upsertados com dedup por external_id.
 */
async function fetchPlatformEarnings(
  _platform: string,
  _userId: string,
  _lookbackDays: number,
): Promise<SyncEarningRow[]> {
  // TODO: implementar adapters reais
  // - uber: Uber Driver API / partner aggregator
  // - 99: 99 driver earnings endpoint
  // - indrive: InDrive partner API
  return [];
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return clientError("Método não suportado.", 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return clientError("Não autenticado.", 401);
  }

  let body: { platform?: string; lookback_days?: number };
  try {
    body = await req.json();
  } catch {
    return clientError("JSON inválido.");
  }

  const platform = body.platform?.toLowerCase();
  if (!platform || !INTEGRATABLE_PLATFORMS.has(platform)) {
    return clientError("Plataforma inválida. Use uber, 99 ou indrive.");
  }

  const lookbackDays = Math.min(Math.max(body.lookback_days ?? 30, 1), 90);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) {
    return clientError("Sessão inválida.", 401);
  }

  const userId = userData.user.id;

  const { data: connection, error: connError } = await supabase
    .from("platform_connections")
    .select("id, status")
    .eq("user_id", userId)
    .eq("platform", platform)
    .maybeSingle();

  if (connError) {
    return clientError(connError.message, 500);
  }

  if (!connection || connection.status === "disconnected") {
    return clientError("Plataforma não conectada.", 409);
  }

  const rows = await fetchPlatformEarnings(platform, userId, lookbackDays);
  let importedCount = 0;
  let skippedCount = 0;
  const syncedAt = new Date().toISOString();

  for (const row of rows) {
    const { error: upsertError } = await supabase.from("earnings").upsert(
      {
        user_id: userId,
        platform,
        amount: row.amount,
        rides: row.rides,
        worked_hours: row.worked_hours,
        date: row.date,
        note: row.note ?? null,
        source: "api_sync",
        external_id: row.external_id,
      },
      { onConflict: "user_id,platform,external_id", ignoreDuplicates: false },
    );

    if (upsertError) {
      skippedCount += 1;
    } else {
      importedCount += 1;
    }
  }

  await supabase
    .from("platform_connections")
    .update({
      status: "connected",
      last_synced_at: syncedAt,
      last_sync_error: null,
    })
    .eq("user_id", userId)
    .eq("platform", platform);

  const message = rows.length === 0
    ? `Adapter ${platform} pronto — aguardando credenciais OAuth no servidor.`
    : undefined;

  return jsonResponse({
    platform,
    imported_count: importedCount,
    skipped_count: skippedCount,
    synced_at: syncedAt,
    message,
  });
});
