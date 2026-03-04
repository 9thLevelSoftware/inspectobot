create extension if not exists pgcrypto;

create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.organization_memberships (
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'inspector',
  created_at timestamptz not null default now(),
  primary key (organization_id, user_id)
);

create table if not exists public.inspector_profiles (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  license_type text,
  license_number text,
  updated_at timestamptz not null default now(),
  unique (organization_id, user_id)
);

create table if not exists public.inspector_signatures (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  storage_path text not null,
  file_hash text not null,
  captured_at timestamptz not null,
  created_at timestamptz not null default now(),
  unique (organization_id, user_id)
);

alter table public.organization_memberships enable row level security;
alter table public.inspector_profiles enable row level security;
alter table public.inspector_signatures enable row level security;

create policy "memberships_select_own"
  on public.organization_memberships for select
  using (
    auth.uid() is not null
    and user_id = auth.uid()
  );

create policy "memberships_insert_self"
  on public.organization_memberships for insert
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
  );

create policy "memberships_update_self"
  on public.organization_memberships for update
  using (
    auth.uid() is not null
    and user_id = auth.uid()
  )
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
  );

create policy "memberships_delete_self"
  on public.organization_memberships for delete
  using (
    auth.uid() is not null
    and user_id = auth.uid()
  );

create policy "profiles_select_org_members"
  on public.inspector_profiles for select
  using (
    auth.uid() is not null
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspector_profiles.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "profiles_insert_org_members"
  on public.inspector_profiles for insert
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspector_profiles.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "profiles_update_org_members"
  on public.inspector_profiles for update
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspector_profiles.organization_id
        and m.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspector_profiles.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "profiles_delete_org_members"
  on public.inspector_profiles for delete
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspector_profiles.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "signatures_select_org_members"
  on public.inspector_signatures for select
  using (
    auth.uid() is not null
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspector_signatures.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "signatures_insert_org_members"
  on public.inspector_signatures for insert
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspector_signatures.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "signatures_update_org_members"
  on public.inspector_signatures for update
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspector_signatures.organization_id
        and m.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspector_signatures.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "signatures_delete_org_members"
  on public.inspector_signatures for delete
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspector_signatures.organization_id
        and m.user_id = auth.uid()
    )
  );
