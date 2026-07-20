-- DriveFlow migration 017 — production security hardening

-- Secrets table: explicit deny for client roles
revoke all on public.platform_connection_secrets from public, anon, authenticated;
grant all on public.platform_connection_secrets to service_role;
alter table public.platform_connection_secrets force row level security;

-- platform_trips: read-only for authenticated clients
drop policy if exists platform_trips_insert_own on public.platform_trips;
drop policy if exists platform_trips_update_own on public.platform_trips;
drop policy if exists platform_trips_delete_own on public.platform_trips;

-- Sync audit logs: only edge functions (service_role) may insert
drop policy if exists platform_sync_logs_insert_own on public.platform_sync_logs;

-- OAuth states: clients do not need to read CSRF tokens
drop policy if exists platform_oauth_states_select_own on public.platform_oauth_states;

-- platform_connections: clients cannot delete rows
drop policy if exists platform_connections_delete_own on public.platform_connections;

-- Prevent clients from forging synced earnings
create or replace function public.enforce_earnings_client_writes()
returns trigger
language plpgsql
as $$
begin
  if auth.role() = 'service_role' then
    return coalesce(new, old);
  end if;

  if tg_op = 'INSERT' then
    if new.source not in ('manual', 'import') then
      raise exception 'source not allowed for client writes';
    end if;
    return new;
  elsif tg_op = 'UPDATE' then
    if old.source = 'api_sync' or new.source = 'api_sync' then
      raise exception 'api_sync earnings are read-only';
    end if;
    return new;
  elsif tg_op = 'DELETE' then
    if old.source = 'api_sync' then
      raise exception 'api_sync earnings cannot be deleted by client';
    end if;
    return old;
  end if;

  return coalesce(new, old);
end;
$$;

drop trigger if exists earnings_enforce_client_writes on public.earnings;
create trigger earnings_enforce_client_writes
before insert or update or delete on public.earnings
for each row execute function public.enforce_earnings_client_writes();

-- Restrict platform_connections writes from authenticated clients
create or replace function public.enforce_platform_connections_client_writes()
returns trigger
language plpgsql
as $$
begin
  if auth.role() = 'service_role' then
    return new;
  end if;

  if tg_op = 'INSERT' then
    if new.status not in ('disconnected', 'pending') then
      raise exception 'invalid status for client insert';
    end if;
    new.external_account_id := null;
    new.sync_cursor := '{}'::jsonb;
    new.last_synced_at := null;
    new.next_scheduled_sync_at := null;
    return new;
  elsif tg_op = 'UPDATE' then
    if new.status = 'disconnected' and old.status is distinct from 'disconnected' then
      new.external_account_id := null;
      new.sync_cursor := '{}'::jsonb;
      new.next_scheduled_sync_at := null;
      new.metadata := '{}'::jsonb;
      return new;
    end if;
    if new.status = 'pending'
      and old.status in ('disconnected', 'error', 'token_expired') then
      new.external_account_id := null;
      new.sync_cursor := '{}'::jsonb;
      new.last_synced_at := null;
      new.next_scheduled_sync_at := null;
      return new;
    end if;
    raise exception 'platform_connections update not allowed';
  end if;

  return new;
end;
$$;

drop trigger if exists platform_connections_enforce_client_writes
  on public.platform_connections;
create trigger platform_connections_enforce_client_writes
before insert or update on public.platform_connections
for each row execute function public.enforce_platform_connections_client_writes();

-- Strip oauth keys from client-writable metadata
create or replace function public.strip_oauth_from_connection_metadata()
returns trigger
language plpgsql
as $$
begin
  if new.metadata ? 'oauth' then
    new.metadata := new.metadata - 'oauth';
  end if;
  return new;
end;
$$;

drop trigger if exists platform_connections_strip_oauth_metadata
  on public.platform_connections;
create trigger platform_connections_strip_oauth_metadata
before insert or update on public.platform_connections
for each row execute function public.strip_oauth_from_connection_metadata();

-- Profiles: email synced from auth only
create or replace function public.protect_profile_email()
returns trigger
language plpgsql
as $$
begin
  if auth.role() != 'service_role' and new.email is distinct from old.email then
    new.email := old.email;
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_protect_email on public.profiles;
create trigger profiles_protect_email
before update on public.profiles
for each row execute function public.protect_profile_email();

-- AI history type constraint
alter table public.ai_history
  drop constraint if exists ai_history_type_check;
alter table public.ai_history
  add constraint ai_history_type_check
  check (type in ('chat', 'forecast'));

-- New users: driver_type chosen in onboarding, not from signup metadata
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, name, driver_type)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'name', new.raw_user_meta_data ->> 'full_name'),
    null
  )
  on conflict (id) do update
    set email = excluded.email,
        name = coalesce(excluded.name, public.profiles.name),
        updated_at = timezone('utc', now());
  return new;
end;
$$;

-- Storage buckets: restrict MIME types
update storage.buckets
set allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
where id in ('receipts', 'avatars');

-- Cleanup helper for expired OAuth states (call from cron or edge function)
create or replace function public.cleanup_expired_oauth_states()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  deleted_count integer;
begin
  delete from public.platform_oauth_states
  where expires_at < timezone('utc', now());
  get diagnostics deleted_count = row_count;
  return deleted_count;
end;
$$;

revoke all on function public.cleanup_expired_oauth_states() from public, anon, authenticated;
grant execute on function public.cleanup_expired_oauth_states() to service_role;
