create extension if not exists pgcrypto;

create table if not exists public.inspections (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  client_name text not null check (length(trim(client_name)) > 0),
  client_email text not null check (length(trim(client_email)) > 0),
  client_phone text not null check (length(trim(client_phone)) > 0),
  property_address text not null check (length(trim(property_address)) > 0),
  inspection_date date not null,
  year_built int not null check (
    year_built >= 1800
    and year_built <= extract(year from now())::int + 1
  ),
  forms_enabled text[] not null check (
    coalesce(array_length(forms_enabled, 1), 0) >= 1
    and forms_enabled <@ array['four_point', 'roof_condition', 'wind_mitigation']::text[]
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.inspections enable row level security;

create policy "inspections_select_org_members"
  on public.inspections for select
  using (
    auth.uid() is not null
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspections.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "inspections_insert_org_members"
  on public.inspections for insert
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspections.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "inspections_update_org_members"
  on public.inspections for update
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspections.organization_id
        and m.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspections.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "inspections_delete_org_members"
  on public.inspections for delete
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspections.organization_id
        and m.user_id = auth.uid()
    )
  );
