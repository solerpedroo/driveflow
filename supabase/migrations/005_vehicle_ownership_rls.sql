-- DriveFlow migration 005 — reforça ownership de vehicle_id nas políticas RLS

drop policy if exists "fuel_logs_all_own" on public.fuel_logs;
create policy "fuel_logs_all_own" on public.fuel_logs
  for all using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.vehicles v
      where v.id = vehicle_id and v.user_id = auth.uid()
    )
  );

drop policy if exists "maintenance_all_own" on public.maintenance;
create policy "maintenance_all_own" on public.maintenance
  for all using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.vehicles v
      where v.id = vehicle_id and v.user_id = auth.uid()
    )
  );

drop policy if exists "earnings_all_own" on public.earnings;
create policy "earnings_all_own" on public.earnings
  for all using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and (
      vehicle_id is null
      or exists (
        select 1 from public.vehicles v
        where v.id = vehicle_id and v.user_id = auth.uid()
      )
    )
  );

drop policy if exists "expenses_all_own" on public.expenses;
create policy "expenses_all_own" on public.expenses
  for all using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and (
      vehicle_id is null
      or exists (
        select 1 from public.vehicles v
        where v.id = vehicle_id and v.user_id = auth.uid()
      )
    )
  );
