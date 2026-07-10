-- DriveFlow migration 004 — histórico de corridas sincronizadas (Onda 25)
-- Corridas individuais por plataforma com dedup por external_id

create table if not exists public.platform_trips (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null check (platform in ('uber', '99', 'indrive')),
  external_id text not null,
  fare_amount numeric(12, 2) not null default 0 check (fare_amount >= 0),
  tip_amount numeric(12, 2) not null default 0 check (tip_amount >= 0),
  platform_fee numeric(12, 2) not null default 0 check (platform_fee >= 0),
  driver_payout numeric(12, 2) not null default 0 check (driver_payout >= 0),
  distance_km numeric(8, 2),
  duration_minutes integer check (duration_minutes is null or duration_minutes >= 0),
  started_at timestamptz not null,
  ended_at timestamptz,
  pickup_label text,
  dropoff_label text,
  status text not null default 'completed'
    check (status in ('completed', 'cancelled', 'adjusted')),
  vehicle_id uuid references public.vehicles (id) on delete set null,
  raw_payload jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (user_id, platform, external_id)
);

create index if not exists platform_trips_user_started_idx
  on public.platform_trips (user_id, started_at desc);

create index if not exists platform_trips_user_platform_started_idx
  on public.platform_trips (user_id, platform, started_at desc);

create trigger platform_trips_set_updated_at
before update on public.platform_trips
for each row execute function public.set_updated_at();

alter table public.platform_trips enable row level security;

create policy platform_trips_select_own
  on public.platform_trips for select
  using (auth.uid() = user_id);

create policy platform_trips_insert_own
  on public.platform_trips for insert
  with check (auth.uid() = user_id);

create policy platform_trips_update_own
  on public.platform_trips for update
  using (auth.uid() = user_id);

create policy platform_trips_delete_own
  on public.platform_trips for delete
  using (auth.uid() = user_id);

-- Constraint explícita para upsert de earnings via API (PostgREST onConflict)
drop index if exists earnings_user_platform_external_id_idx;

alter table public.earnings
  drop constraint if exists earnings_user_platform_external_unique;

alter table public.earnings
  add constraint earnings_user_platform_external_unique
  unique (user_id, platform, external_id);
