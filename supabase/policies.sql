-- Development policies (permissive) for anon access via REST
-- WARNING: For development/testing only. Tighten for production.

-- Users policies
create policy if not exists "users_select_anon" on public.users
  for select
  using (true);

create policy if not exists "users_insert_anon" on public.users
  for insert
  with check (true);

create policy if not exists "users_update_anon" on public.users
  for update
  using (true)
  with check (true);

-- Loads policies
create policy if not exists "loads_select_anon" on public.loads
  for select
  using (true);

create policy if not exists "loads_insert_anon" on public.loads
  for insert
  with check (true);

create policy if not exists "loads_update_anon" on public.loads
  for update
  using (true)
  with check (true);