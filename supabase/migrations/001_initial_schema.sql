-- DriveFlow initial schema (MVP v1.0)
-- Migration 001: profiles, vehicles, earnings, expenses, fuel_logs, maintenance, goals, ai_history

-- Extensions
create extension if not exists "pgcrypto";

-- Updated_at trigger helper
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

-- Profiles (extends auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text,
  email text,
  photo text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

-- Vehicles
create table if not exists public.vehicles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  brand text not null,
  model text not null,
  year integer not null check (year >= 1980 and year <= 2100),
  plate text,
  fuel text not null default 'flex',
  tank numeric(8, 2),
  avg_consumption numeric(6, 2),
  odometer numeric(10, 1) not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists vehicles_user_id_idx on public.vehicles (user_id);

create trigger vehicles_set_updated_at
before update on public.vehicles
for each row execute function public.set_updated_at();

-- Earnings
create table if not exists public.earnings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null,
  amount numeric(12, 2) not null check (amount >= 0),
  rides integer not null default 0 check (rides >= 0),
  worked_hours numeric(6, 2) not null default 0 check (worked_hours >= 0),
  note text,
  date timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists earnings_user_id_date_idx
  on public.earnings (user_id, date desc);

create trigger earnings_set_updated_at
before update on public.earnings
for each row execute function public.set_updated_at();

-- Expenses
create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  category text not null,
  amount numeric(12, 2) not null check (amount >= 0),
  description text,
  receipt_url text,
  date timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists expenses_user_id_date_idx
  on public.expenses (user_id, date desc);

create index if not exists expenses_user_id_category_idx
  on public.expenses (user_id, category);

create trigger expenses_set_updated_at
before update on public.expenses
for each row execute function public.set_updated_at();

-- Fuel logs
create table if not exists public.fuel_logs (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  station text,
  fuel_type text not null default 'gasoline',
  price_per_liter numeric(8, 3) not null check (price_per_liter >= 0),
  liters numeric(8, 3) not null check (liters > 0),
  total_amount numeric(12, 2) not null check (total_amount >= 0),
  odometer numeric(10, 1) not null check (odometer >= 0),
  km_per_liter numeric(6, 2),
  cost_per_km numeric(8, 4),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists fuel_logs_vehicle_id_idx
  on public.fuel_logs (vehicle_id, created_at desc);

create index if not exists fuel_logs_user_id_idx
  on public.fuel_logs (user_id, created_at desc);

create trigger fuel_logs_set_updated_at
before update on public.fuel_logs
for each row execute function public.set_updated_at();

-- Maintenance
create table if not exists public.maintenance (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  type text not null,
  cost numeric(12, 2) not null default 0 check (cost >= 0),
  notes text,
  service_date timestamptz not null default timezone('utc', now()),
  next_due_km numeric(10, 1),
  next_due_date date,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists maintenance_vehicle_id_idx
  on public.maintenance (vehicle_id, service_date desc);

create trigger maintenance_set_updated_at
before update on public.maintenance
for each row execute function public.set_updated_at();

-- Goals (one row per user)
create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users (id) on delete cascade,
  daily numeric(12, 2) not null default 0 check (daily >= 0),
  weekly numeric(12, 2) not null default 0 check (weekly >= 0),
  monthly numeric(12, 2) not null default 0 check (monthly >= 0),
  yearly numeric(12, 2) not null default 0 check (yearly >= 0),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create trigger goals_set_updated_at
before update on public.goals
for each row execute function public.set_updated_at();

-- AI history
create table if not exists public.ai_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  question text not null,
  answer text not null,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists ai_history_user_id_idx
  on public.ai_history (user_id, created_at desc);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'name', new.raw_user_meta_data ->> 'full_name')
  )
  on conflict (id) do update
    set email = excluded.email,
        updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Row Level Security
alter table public.profiles enable row level security;
alter table public.vehicles enable row level security;
alter table public.earnings enable row level security;
alter table public.expenses enable row level security;
alter table public.fuel_logs enable row level security;
alter table public.maintenance enable row level security;
alter table public.goals enable row level security;
alter table public.ai_history enable row level security;

-- Profiles policies
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

-- Vehicles policies
create policy "vehicles_all_own" on public.vehicles
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Earnings policies
create policy "earnings_all_own" on public.earnings
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Expenses policies
create policy "expenses_all_own" on public.expenses
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Fuel logs policies
create policy "fuel_logs_all_own" on public.fuel_logs
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Maintenance policies
create policy "maintenance_all_own" on public.maintenance
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Goals policies
create policy "goals_all_own" on public.goals
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- AI history policies
create policy "ai_history_all_own" on public.ai_history
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Storage buckets
insert into storage.buckets (id, name, public)
values
  ('receipts', 'receipts', false),
  ('avatars', 'avatars', false)
on conflict (id) do nothing;

-- Storage policies: receipts
create policy "receipts_select_own" on storage.objects
  for select using (
    bucket_id = 'receipts'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "receipts_insert_own" on storage.objects
  for insert with check (
    bucket_id = 'receipts'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "receipts_update_own" on storage.objects
  for update using (
    bucket_id = 'receipts'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "receipts_delete_own" on storage.objects
  for delete using (
    bucket_id = 'receipts'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Storage policies: avatars
create policy "avatars_select_own" on storage.objects
  for select using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "avatars_insert_own" on storage.objects
  for insert with check (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "avatars_update_own" on storage.objects
  for update using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "avatars_delete_own" on storage.objects
  for delete using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
