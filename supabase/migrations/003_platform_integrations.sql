-- DriveFlow migration 003 — integrações Uber, 99 e InDrive (Onda 24)
-- Conexões de plataforma, proveniência de ganhos e dedup por external_id

-- Conexões OAuth/API por motorista e plataforma
create table if not exists public.platform_connections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null check (platform in ('uber', '99', 'indrive')),
  status text not null default 'disconnected'
    check (status in ('disconnected', 'pending', 'connected', 'error', 'token_expired')),
  external_account_id text,
  last_synced_at timestamptz,
  last_sync_error text,
  sync_cursor jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (user_id, platform)
);

create index if not exists platform_connections_user_id_idx
  on public.platform_connections (user_id);

create trigger platform_connections_set_updated_at
before update on public.platform_connections
for each row execute function public.set_updated_at();

-- Proveniência e dedup de ganhos sincronizados via API
alter table public.earnings
  add column if not exists source text not null default 'manual'
    check (source in ('manual', 'import', 'api_sync')),
  add column if not exists external_id text;

create unique index if not exists earnings_user_platform_external_id_idx
  on public.earnings (user_id, platform, external_id)
  where external_id is not null;

create index if not exists earnings_user_source_date_idx
  on public.earnings (user_id, source, date desc);

-- RLS
alter table public.platform_connections enable row level security;

create policy platform_connections_select_own
  on public.platform_connections for select
  using (auth.uid() = user_id);

create policy platform_connections_insert_own
  on public.platform_connections for insert
  with check (auth.uid() = user_id);

create policy platform_connections_update_own
  on public.platform_connections for update
  using (auth.uid() = user_id);

create policy platform_connections_delete_own
  on public.platform_connections for delete
  using (auth.uid() = user_id);
