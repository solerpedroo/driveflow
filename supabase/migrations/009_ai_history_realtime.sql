-- Habilita Realtime para ai_history (chat e previsões)
do $$ begin
  alter publication supabase_realtime add table public.ai_history;
exception when duplicate_object then null;
end $$;
