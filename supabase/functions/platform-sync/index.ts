import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const allowedOrigin = Deno.env.get("ALLOWED_ORIGIN") ?? "";

const corsHeaders = {
  "Access-Control-Allow-Origin": allowedOrigin || "null",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const INTEGRATABLE_PLATFORMS = new Set(["uber", "99", "indrive"]);

type SyncTripRow = {
  external_id: string;
  fare_amount: number;
  tip_amount: number;
  platform_fee: number;
  driver_payout: number;
  distance_km?: number;
  duration_minutes?: number;
  started_at: string;
  ended_at?: string;
  pickup_label?: string;
  dropoff_label?: string;
  status?: string;
};

type DailyRollup = {
  external_id: string;
  amount: number;
  rides: number;
  worked_hours: number;
  date: string;
  note: string;
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

function dayKey(platform: string, isoDate: string) {
  const day = isoDate.substring(0, 10);
  return `${platform}:${day}`;
}

function rollupDaily(platform: string, trips: SyncTripRow[]): DailyRollup[] {
  const buckets = new Map<string, SyncTripRow[]>();

  for (const trip of trips) {
    if ((trip.status ?? "completed") !== "completed") continue;
    const key = dayKey(platform, trip.started_at);
    const list = buckets.get(key) ?? [];
    list.push(trip);
    buckets.set(key, list);
  }

  const rollups: DailyRollup[] = [];
  for (const [, dayTrips] of buckets) {
    const day = dayTrips[0].started_at.substring(0, 10);
    const amount = dayTrips.reduce((sum, t) => sum + t.driver_payout, 0);
    const hours = dayTrips.reduce(
      (sum, t) => sum + (t.duration_minutes ?? 0) / 60,
      0,
    );

    rollups.push({
      external_id: `rollup:${platform}:${day}`,
      amount: Number(amount.toFixed(2)),
      rides: dayTrips.length,
      worked_hours: Number(hours.toFixed(2)),
      date: `${day}T12:00:00.000Z`,
      note: `Sync automático · ${dayTrips.length} corridas`,
    });
  }

  return rollups;
}

/**
 * Stub — adapters reais em adapters.ts
 */
async function fetchPlatformTrips(
  platform: string,
  userId: string,
  lookbackDays: number,
): Promise<SyncTripRow[]> {
  const { fetchUberTrips, fetchNinetyNineTrips, fetchInDriveTrips } = await import(
    "./adapters.ts"
  );
  switch (platform) {
    case "uber":
      return fetchUberTrips(userId, lookbackDays);
    case "99":
      return fetchNinetyNineTrips(userId, lookbackDays);
    case "indrive":
      return fetchInDriveTrips(userId, lookbackDays);
    default:
      return [];
  }
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

  let body: { platform?: string; lookback_days?: number; trigger_source?: string };
  try {
    body = await req.json();
  } catch {
    return clientError("JSON inválido.");
  }

  const triggerSource = body.trigger_source ?? "manual";

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

  const tripRows = await fetchPlatformTrips(platform, userId, lookbackDays);
  let tripsImported = 0;
  let earningsImported = 0;
  let skippedCount = 0;
  const syncedAt = new Date().toISOString();

  for (const trip of tripRows) {
    const { error: tripError } = await supabase.from("platform_trips").upsert(
      {
        user_id: userId,
        platform,
        external_id: trip.external_id,
        fare_amount: trip.fare_amount,
        tip_amount: trip.tip_amount,
        platform_fee: trip.platform_fee,
        driver_payout: trip.driver_payout,
        distance_km: trip.distance_km ?? null,
        duration_minutes: trip.duration_minutes ?? null,
        started_at: trip.started_at,
        ended_at: trip.ended_at ?? null,
        pickup_label: trip.pickup_label ?? null,
        dropoff_label: trip.dropoff_label ?? null,
        status: trip.status ?? "completed",
      },
      { onConflict: "user_id,platform,external_id", ignoreDuplicates: false },
    );

    if (tripError) {
      skippedCount += 1;
    } else {
      tripsImported += 1;
    }
  }

  const rollups = rollupDaily(platform, tripRows);
  for (const rollup of rollups) {
    const { data: existing } = await supabase
      .from("earnings")
      .select("source")
      .eq("user_id", userId)
      .eq("platform", platform)
      .eq("external_id", rollup.external_id)
      .maybeSingle();

    if (existing?.source === "manual") {
      skippedCount += 1;
      continue;
    }

    const { error: earningError } = await supabase.from("earnings").upsert(
      {
        user_id: userId,
        platform,
        amount: rollup.amount,
        rides: rollup.rides,
        worked_hours: rollup.worked_hours,
        date: rollup.date,
        note: rollup.note,
        source: "api_sync",
        external_id: rollup.external_id,
      },
      { onConflict: "user_id,platform,external_id", ignoreDuplicates: false },
    );

    if (earningError) {
      skippedCount += 1;
    } else {
      earningsImported += 1;
    }
  }

  await supabase
    .from("platform_connections")
    .update({
      status: "connected",
      last_synced_at: syncedAt,
      last_sync_error: null,
      next_scheduled_sync_at: new Date(Date.now() + 24 * 3600 * 1000).toISOString(),
    })
    .eq("user_id", userId)
    .eq("platform", platform);

  await supabase.from("platform_sync_logs").insert({
    user_id: userId,
    platform,
    trigger_source: triggerSource,
    trips_imported: tripsImported,
    earnings_imported: earningsImported,
    skipped_count: skippedCount,
    status: skippedCount > 0 && tripsImported + earningsImported > 0
      ? "partial"
      : skippedCount > 0
      ? "error"
      : "success",
    message: tripRows.length === 0
      ? `Adapter ${platform} pronto — aguardando credenciais OAuth.`
      : null,
  });

  const message = tripRows.length === 0
    ? `Adapter ${platform} pronto — aguardando credenciais OAuth. Corridas e ganhos serão sincronizados automaticamente.`
    : undefined;

  return jsonResponse({
    platform,
    trips_imported: tripsImported,
    earnings_imported: earningsImported,
    imported_count: tripsImported + earningsImported,
    skipped_count: skippedCount,
    synced_at: syncedAt,
    message,
  });
});
