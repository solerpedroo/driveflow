-- Migration 008: tipo de motorista (app vs taxista) + onboarding de boas-vindas

alter table public.profiles
  add column if not exists driver_type text
    check (driver_type in ('ride_share', 'taxi'));

alter table public.profiles
  add column if not exists onboarding_completed_at timestamptz;

-- Usuários existentes permanecem como motoristas de aplicativo
update public.profiles
set driver_type = 'ride_share'
where driver_type is null;

-- Usuários existentes não passam pelo onboarding editorial novamente
update public.profiles
set onboarding_completed_at = timezone('utc', now())
where onboarding_completed_at is null;

create index if not exists profiles_driver_type_idx
  on public.profiles (driver_type);

-- Novos usuários OAuth podem escolher o tipo no primeiro acesso
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
    coalesce(new.raw_user_meta_data ->> 'driver_type', null)
  )
  on conflict (id) do update
    set email = excluded.email,
        name = coalesce(excluded.name, public.profiles.name),
        driver_type = coalesce(
          excluded.driver_type,
          public.profiles.driver_type
        ),
        updated_at = timezone('utc', now());
  return new;
end;
$$;
