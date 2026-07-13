-- DriveFlow migration 014 — histórico de turnos (modo turno)

create table if not exists public.shift_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  vehicle_id uuid references public.vehicles (id) on delete set null,
  started_at timestamptz not null,
  ended_at timestamptz not null,
  elapsed_ms bigint not null default 0 check (elapsed_ms >= 0),
  accumulated_pause_ms bigint not null default 0 check (accumulated_pause_ms >= 0),
  is_taxi_mode boolean not null default false,
  status text not null default 'completed'
    check (status in ('active', 'paused', 'completed')),
  plan_blocks jsonb not null default '[]'::jsonb,
  revenue numeric(12, 2) not null default 0 check (revenue >= 0),
  rides integer not null default 0 check (rides >= 0),
  revenue_per_hour numeric(12, 2),
  adherence_score numeric(5, 2) not null default 0
    check (adherence_score >= 0 and adherence_score <= 100),
  matched_plan_blocks integer not null default 0 check (matched_plan_blocks >= 0),
  total_plan_blocks integer not null default 0 check (total_plan_blocks >= 0),
  revenue_by_platform jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists shift_sessions_user_started_idx
  on public.shift_sessions (user_id, started_at desc);

create trigger shift_sessions_set_updated_at
before update on public.shift_sessions
for each row execute function public.set_updated_at();

alter table public.shift_sessions enable row level security;

create policy "shift_sessions_all_own" on public.shift_sessions
  for all using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and (
      vehicle_id is null
      or exists (
        select 1 from public.vehicles v
        where v.id = vehicle_id and v.user_id = auth.uid()
      )
    )
  );

alter publication supabase_realtime add table public.shift_sessions;
