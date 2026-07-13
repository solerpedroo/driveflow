-- DriveFlow migration 015 — snapshot de blocos na retrospectiva de turno

alter table public.shift_sessions
  add column if not exists block_outcomes jsonb not null default '[]'::jsonb;
