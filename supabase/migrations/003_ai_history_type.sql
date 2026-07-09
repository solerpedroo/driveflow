-- Tipo opcional no histórico de IA (chat vs previsão).
alter table public.ai_history
  add column if not exists type text not null default 'chat';

create index if not exists ai_history_user_type_idx
  on public.ai_history (user_id, type, created_at desc);
