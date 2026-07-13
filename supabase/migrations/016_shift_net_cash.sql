-- DriveFlow migration 016 — caixa líquido no histórico de turnos

alter table public.shift_sessions
  add column if not exists expenses numeric(12, 2) not null default 0
    check (expenses >= 0),
  add column if not exists net_cash numeric(12, 2) not null default 0,
  add column if not exists expenses_by_category jsonb not null default '{}'::jsonb;

update public.shift_sessions
set net_cash = revenue - expenses
where net_cash = 0 and revenue > 0;
