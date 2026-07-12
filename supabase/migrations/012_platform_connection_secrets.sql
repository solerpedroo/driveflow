-- DriveFlow migration 012 — OAuth secrets fora do metadata client-readable (P0-8)

create table if not exists public.platform_connection_secrets (
  connection_id uuid primary key
    references public.platform_connections (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  oauth jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists platform_connection_secrets_user_idx
  on public.platform_connection_secrets (user_id);

create trigger platform_connection_secrets_set_updated_at
before update on public.platform_connection_secrets
for each row execute function public.set_updated_at();

alter table public.platform_connection_secrets enable row level security;

-- Sem policies para authenticated — apenas service_role (edge functions) acessa.

insert into public.platform_connection_secrets (connection_id, user_id, oauth)
select
  pc.id,
  pc.user_id,
  pc.metadata -> 'oauth'
from public.platform_connections pc
where pc.metadata ? 'oauth'
  and pc.metadata -> 'oauth' is not null
on conflict (connection_id) do update
set
  oauth = excluded.oauth,
  updated_at = timezone('utc', now());

update public.platform_connections
set metadata = metadata - 'oauth'
where metadata ? 'oauth';

create or replace function public.clear_connection_secrets_on_disconnect()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status = 'disconnected'
    and old.status is distinct from 'disconnected' then
    delete from public.platform_connection_secrets
    where connection_id = new.id;
  end if;
  return new;
end;
$$;

drop trigger if exists platform_connections_clear_secrets_on_disconnect
  on public.platform_connections;

create trigger platform_connections_clear_secrets_on_disconnect
after update on public.platform_connections
for each row execute function public.clear_connection_secrets_on_disconnect();
