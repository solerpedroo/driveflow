-- DriveFlow migration 005 — OAuth states, sync logs e agendamento (Ondas 26–28)

-- Estados temporários OAuth (CSRF protection)
create table if not exists public.platform_oauth_states (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null check (platform in ('uber', '99', 'indrive')),
  state_token text not null unique,
  redirect_uri text not null,
  expires_at timestamptz not null,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists platform_oauth_states_user_platform_idx
  on public.platform_oauth_states (user_id, platform);

-- Log auditável de sincronizações
create table if not exists public.platform_sync_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null check (platform in ('uber', '99', 'indrive')),
  trigger_source text not null default 'manual'
    check (trigger_source in ('manual', 'cron', 'webhook', 'app_background')),
  trips_imported integer not null default 0,
  earnings_imported integer not null default 0,
  skipped_count integer not null default 0,
  status text not null default 'success'
    check (status in ('success', 'partial', 'error')),
  message text,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists platform_sync_logs_user_created_idx
  on public.platform_sync_logs (user_id, created_at desc);

-- Agendamento de próxima sync automática
alter table public.platform_connections
  add column if not exists next_scheduled_sync_at timestamptz;

-- Tokens OAuth ficam em metadata (criptografados pela Edge Function)
-- sync_cursor já existe em 003 — usado para paginação incremental

alter table public.platform_oauth_states enable row level security;
alter table public.platform_sync_logs enable row level security;

create policy platform_oauth_states_select_own
  on public.platform_oauth_states for select using (auth.uid() = user_id);

create policy platform_oauth_states_insert_own
  on public.platform_oauth_states for insert with check (auth.uid() = user_id);

create policy platform_oauth_states_delete_own
  on public.platform_oauth_states for delete using (auth.uid() = user_id);

create policy platform_sync_logs_select_own
  on public.platform_sync_logs for select using (auth.uid() = user_id);

create policy platform_sync_logs_insert_own
  on public.platform_sync_logs for insert with check (auth.uid() = user_id);
