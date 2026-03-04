create table if not exists public.report_readiness (
  inspection_id uuid primary key references public.inspections(id) on delete cascade,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null check (status in ('ready', 'blocked')),
  missing_items text[] not null default '{}'::text[],
  computed_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (
    (status = 'ready' and coalesce(array_length(missing_items, 1), 0) = 0)
    or (status = 'blocked' and coalesce(array_length(missing_items, 1), 0) >= 1)
  )
);

create index if not exists report_readiness_org_user_idx
  on public.report_readiness (organization_id, user_id);

alter table public.report_readiness enable row level security;

create policy "report_readiness_select_org_members"
  on public.report_readiness for select
  using (
    auth.uid() is not null
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_readiness.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "report_readiness_insert_org_members"
  on public.report_readiness for insert
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_readiness.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "report_readiness_update_org_members"
  on public.report_readiness for update
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_readiness.organization_id
        and m.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_readiness.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "report_readiness_delete_org_members"
  on public.report_readiness for delete
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_readiness.organization_id
        and m.user_id = auth.uid()
    )
  );
