create table if not exists public.inspection_media_assets (
  id uuid primary key,
  inspection_id uuid not null references public.inspections(id) on delete cascade,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null,
  storage_path text not null check (length(trim(storage_path)) > 0),
  captured_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (inspection_id, category)
);

alter table public.inspection_media_assets enable row level security;

create policy "inspection_media_assets_select_org_members"
  on public.inspection_media_assets for select
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspection_media_assets.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "inspection_media_assets_insert_org_members"
  on public.inspection_media_assets for insert
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspection_media_assets.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "inspection_media_assets_update_org_members"
  on public.inspection_media_assets for update
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspection_media_assets.organization_id
        and m.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspection_media_assets.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "inspection_media_assets_delete_org_members"
  on public.inspection_media_assets for delete
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspection_media_assets.organization_id
        and m.user_id = auth.uid()
    )
  );
