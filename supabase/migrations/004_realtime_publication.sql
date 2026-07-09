-- Habilita Realtime para tabelas usadas com .stream() no Flutter (idempotente)
do $$ begin
  alter publication supabase_realtime add table public.vehicles;
exception when duplicate_object then null;
end $$;

do $$ begin
  alter publication supabase_realtime add table public.earnings;
exception when duplicate_object then null;
end $$;

do $$ begin
  alter publication supabase_realtime add table public.expenses;
exception when duplicate_object then null;
end $$;

do $$ begin
  alter publication supabase_realtime add table public.fuel_logs;
exception when duplicate_object then null;
end $$;

do $$ begin
  alter publication supabase_realtime add table public.maintenance;
exception when duplicate_object then null;
end $$;

do $$ begin
  alter publication supabase_realtime add table public.goals;
exception when duplicate_object then null;
end $$;
