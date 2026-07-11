export type SyncTripRow = {
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

export class AdapterNotConfiguredError extends Error {
  constructor(platform: string) {
    super(`Adapter ${platform} não configurado no servidor.`);
    this.name = "AdapterNotConfiguredError";
  }
}

export class AdapterAuthError extends Error {
  constructor(platform: string, detail: string) {
    super(`Autenticação inválida em ${platform}: ${detail}`);
    this.name = "AdapterAuthError";
  }
}

type UberTrip = {
  trip_id?: string;
  fare?: number;
  distance?: number;
  duration?: number;
  status?: string;
  currency_code?: string;
  start_city?: { display_name?: string };
  destination?: { display_name?: string };
  status_changes?: Array<{ status?: string; timestamp?: number }>;
};

type UberTripsResponse = {
  trips?: UberTrip[];
  count?: number;
  limit?: number;
  offset?: number;
};

function unixToIso(seconds?: number): string | undefined {
  if (typeof seconds !== "number" || Number.isNaN(seconds)) return undefined;
  return new Date(seconds * 1000).toISOString();
}

function tripTimestamp(trip: UberTrip, preferred: string[]): string {
  const changes = trip.status_changes ?? [];
  for (const status of preferred) {
    const match = changes.find((item) => item.status === status);
    const iso = unixToIso(match?.timestamp);
    if (iso) return iso;
  }
  const fallback = changes[0]?.timestamp;
  return unixToIso(fallback) ?? new Date().toISOString();
}

function mapUberTrip(trip: UberTrip): SyncTripRow | null {
  const tripId = trip.trip_id;
  if (!tripId) return null;

  const status = (trip.status ?? "completed").toLowerCase();
  const fare = Number(trip.fare ?? 0);
  const startedAt = tripTimestamp(trip, ["trip_began", "accepted", "driver_arrived"]);
  const endedAt = tripTimestamp(trip, ["completed", "rider_canceled", "driver_canceled"]);

  return {
    external_id: tripId,
    fare_amount: fare,
    tip_amount: 0,
    platform_fee: 0,
    driver_payout: status === "completed" ? fare : 0,
    distance_km: typeof trip.distance === "number" ? trip.distance : undefined,
    duration_minutes: typeof trip.duration === "number"
      ? Number((trip.duration / 60).toFixed(2))
      : undefined,
    started_at: startedAt,
    ended_at: endedAt,
    pickup_label: trip.start_city?.display_name,
    dropoff_label: trip.destination?.display_name,
    status,
  };
}

async function fetchUberTripsPage(
  accessToken: string,
  fromTime: number,
  toTime: number,
  offset: number,
): Promise<UberTrip[]> {
  const url = new URL("https://api.uber.com/v1/partners/trips");
  url.searchParams.set("limit", "50");
  url.searchParams.set("offset", String(offset));
  url.searchParams.set("from_time", String(fromTime));
  url.searchParams.set("to_time", String(toTime));

  const response = await fetch(url.toString(), {
    headers: { Authorization: `Bearer ${accessToken}` },
  });

  if (response.status === 401) {
    throw new AdapterAuthError("uber", "Token expirado ou inválido.");
  }

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`Uber API ${response.status}: ${text}`);
  }

  const payload = await response.json() as UberTripsResponse;
  return payload.trips ?? [];
}

export async function fetchUberTrips(
  _userId: string,
  lookbackDays: number,
  accessToken: string,
): Promise<SyncTripRow[]> {
  const toTime = Math.floor(Date.now() / 1000);
  const fromTime = toTime - lookbackDays * 24 * 60 * 60;
  const rows: SyncTripRow[] = [];
  let offset = 0;

  for (let page = 0; page < 20; page++) {
    const trips = await fetchUberTripsPage(accessToken, fromTime, toTime, offset);
    if (trips.length === 0) break;

    for (const trip of trips) {
      const mapped = mapUberTrip(trip);
      if (mapped) rows.push(mapped);
    }

    if (trips.length < 50) break;
    offset += trips.length;
  }

  return rows;
}

type GenericTrip = {
  external_id?: string;
  id?: string;
  trip_id?: string;
  fare_amount?: number;
  fare?: number;
  amount?: number;
  tip_amount?: number;
  tip?: number;
  platform_fee?: number;
  fee?: number;
  driver_payout?: number;
  payout?: number;
  distance_km?: number;
  distance?: number;
  duration_minutes?: number;
  duration?: number;
  started_at?: string;
  start_time?: string;
  ended_at?: string;
  end_time?: string;
  pickup_label?: string;
  pickup?: string;
  dropoff_label?: string;
  dropoff?: string;
  status?: string;
};

async function fetchConfigurableTrips(
  platform: string,
  accessToken: string,
  lookbackDays: number,
  tripsUrlEnv: string,
): Promise<SyncTripRow[]> {
  const tripsUrl = Deno.env.get(tripsUrlEnv)?.trim();
  if (!tripsUrl) {
    throw new AdapterNotConfiguredError(platform);
  }

  const to = new Date().toISOString();
  const from = new Date(Date.now() - lookbackDays * 24 * 60 * 60 * 1000)
    .toISOString();
  const url = new URL(tripsUrl);
  if (!url.searchParams.has("from")) url.searchParams.set("from", from);
  if (!url.searchParams.has("to")) url.searchParams.set("to", to);

  const response = await fetch(url.toString(), {
    headers: { Authorization: `Bearer ${accessToken}` },
  });

  if (response.status === 401) {
    throw new AdapterAuthError(platform, "Token expirado ou inválido.");
  }

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`${platform} API ${response.status}: ${text}`);
  }

  const payload = await response.json() as { trips?: GenericTrip[] } | GenericTrip[];
  const trips = Array.isArray(payload) ? payload : payload.trips ?? [];

  return trips.map((trip) => {
    const fare = Number(trip.fare_amount ?? trip.fare ?? trip.amount ?? 0);
    const payout = Number(trip.driver_payout ?? trip.payout ?? fare);
    const externalId = trip.external_id ?? trip.trip_id ?? trip.id;
    if (!externalId) {
      throw new Error(`Corrida ${platform} sem identificador externo.`);
    }

    return {
      external_id: String(externalId),
      fare_amount: fare,
      tip_amount: Number(trip.tip_amount ?? trip.tip ?? 0),
      platform_fee: Number(trip.platform_fee ?? trip.fee ?? 0),
      driver_payout: payout,
      distance_km: trip.distance_km ?? trip.distance,
      duration_minutes: trip.duration_minutes ?? trip.duration,
      started_at: trip.started_at ?? trip.start_time ?? new Date().toISOString(),
      ended_at: trip.ended_at ?? trip.end_time,
      pickup_label: trip.pickup_label ?? trip.pickup,
      dropoff_label: trip.dropoff_label ?? trip.dropoff,
      status: (trip.status ?? "completed").toLowerCase(),
    };
  });
}

export async function fetchNinetyNineTrips(
  _userId: string,
  lookbackDays: number,
  accessToken: string,
): Promise<SyncTripRow[]> {
  return fetchConfigurableTrips("99", accessToken, lookbackDays, "NINETY_NINE_TRIPS_URL");
}

export async function fetchInDriveTrips(
  _userId: string,
  lookbackDays: number,
  accessToken: string,
): Promise<SyncTripRow[]> {
  return fetchConfigurableTrips("indrive", accessToken, lookbackDays, "INDRIVE_TRIPS_URL");
}
