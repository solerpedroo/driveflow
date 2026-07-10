-- Realtime para tabelas de integrações (Ondas 24–28)
do $$ begin
  alter publication supabase_realtime add table public.platform_connections;
exception when duplicate_object then null;
end $$;

do $$ begin
  alter publication supabase_realtime add table public.platform_trips;
exception when duplicate_object then null;
end $$;

do $$ begin
  alter publication supabase_realtime add table public.platform_sync_logs;
exception when duplicate_object then null;
end $$;
