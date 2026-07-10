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

export async function fetchUberTrips(
  _userId: string,
  _lookbackDays: number,
): Promise<SyncTripRow[]> {
  // TODO: Uber Driver API — GET /v1/partners/trips
  return [];
}

export async function fetchNinetyNineTrips(
  _userId: string,
  _lookbackDays: number,
): Promise<SyncTripRow[]> {
  // TODO: 99 Driver API
  return [];
}

export async function fetchInDriveTrips(
  _userId: string,
  _lookbackDays: number,
): Promise<SyncTripRow[]> {
  // TODO: InDrive Partner API
  return [];
}
