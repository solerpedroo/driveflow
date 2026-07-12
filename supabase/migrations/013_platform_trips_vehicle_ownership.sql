-- DriveFlow migration 013 — valida ownership de vehicle_id em platform_trips

drop policy if exists platform_trips_insert_own on public.platform_trips;
create policy platform_trips_insert_own
  on public.platform_trips for insert
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

drop policy if exists platform_trips_update_own on public.platform_trips;
create policy platform_trips_update_own
  on public.platform_trips for update
  using (auth.uid() = user_id)
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
