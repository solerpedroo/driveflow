-- DriveFlow migration 018 — pendências MEDIUM (PKCE, consentimento IA)

alter table public.platform_oauth_states
  add column if not exists code_verifier text;

alter table public.profiles
  add column if not exists ai_data_consent_at timestamptz;

create index if not exists profiles_ai_consent_idx
  on public.profiles (ai_data_consent_at)
  where ai_data_consent_at is not null;

-- Consentimento IA: usuário pode conceder, mas não revogar via client direto
create or replace function public.protect_ai_data_consent()
returns trigger
language plpgsql
as $$
begin
  if auth.role() = 'service_role' then
    return new;
  end if;

  if old.ai_data_consent_at is not null
    and (new.ai_data_consent_at is null
      or new.ai_data_consent_at < old.ai_data_consent_at) then
    new.ai_data_consent_at := old.ai_data_consent_at;
  end if;

  return new;
end;
$$;

drop trigger if exists profiles_protect_ai_consent on public.profiles;
create trigger profiles_protect_ai_consent
before update on public.profiles
for each row execute function public.protect_ai_data_consent();
