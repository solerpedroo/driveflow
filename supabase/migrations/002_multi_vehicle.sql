-- DriveFlow migration 002 — multi-vehicle (Onda 10)
-- nickname, is_default, optional vehicle_id on earnings/expenses

-- Vehicles: apelido e veículo padrão
alter table public.vehicles
  add column if not exists nickname text,
  add column if not exists is_default boolean not null default false;

-- Apenas um veículo padrão por usuário
create unique index if not exists vehicles_user_id_default_idx
  on public.vehicles (user_id)
  where is_default = true;

-- Ganhos e despesas podem ser vinculados a um veículo (legado: null)
alter table public.earnings
  add column if not exists vehicle_id uuid references public.vehicles (id) on delete set null;

alter table public.expenses
  add column if not exists vehicle_id uuid references public.vehicles (id) on delete set null;

create index if not exists earnings_vehicle_id_date_idx
  on public.earnings (vehicle_id, date desc)
  where vehicle_id is not null;

create index if not exists expenses_vehicle_id_date_idx
  on public.expenses (vehicle_id, date desc)
  where vehicle_id is not null;

-- Garante um default para usuários com veículos legados (nenhum marcado)
update public.vehicles v
set is_default = true
where v.is_default = false
  and not exists (
    select 1
    from public.vehicles v2
    where v2.user_id = v.user_id
      and v2.is_default = true
  )
  and v.id = (
    select v3.id
    from public.vehicles v3
    where v3.user_id = v.user_id
    order by v3.created_at
    limit 1
  );
