create table if not exists public.inspection_audit_events (
  id uuid primary key default gen_random_uuid(),
  inspection_id uuid not null references public.inspections(id) on delete cascade,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  event_type text not null,
  occurred_at timestamptz not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists inspection_audit_events_scope_idx
  on public.inspection_audit_events (organization_id, user_id, inspection_id, occurred_at desc);

create or replace function public.prevent_audit_mutation()
returns trigger
language plpgsql
as $$
begin
  raise exception 'inspection_audit_events is append-only';
end;
$$;

drop trigger if exists inspection_audit_events_no_update on public.inspection_audit_events;
create trigger inspection_audit_events_no_update
before update on public.inspection_audit_events
for each row
execute function public.prevent_audit_mutation();

drop trigger if exists inspection_audit_events_no_delete on public.inspection_audit_events;
create trigger inspection_audit_events_no_delete
before delete on public.inspection_audit_events
for each row
execute function public.prevent_audit_mutation();

create table if not exists public.report_artifacts (
  id uuid primary key default gen_random_uuid(),
  inspection_id uuid not null references public.inspections(id) on delete cascade,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  storage_bucket text not null,
  storage_path text not null,
  file_name text not null,
  content_type text not null,
  size_bytes bigint not null check (size_bytes >= 0),
  payload_hash text,
  signature_hash text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (inspection_id, storage_path)
);

create index if not exists report_artifacts_scope_idx
  on public.report_artifacts (organization_id, user_id, inspection_id, created_at desc);

create table if not exists public.report_delivery_actions (
  id uuid primary key default gen_random_uuid(),
  artifact_id uuid not null references public.report_artifacts(id) on delete cascade,
  inspection_id uuid not null references public.inspections(id) on delete cascade,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  action_type text not null,
  channel text not null,
  correlation_id text,
  payload jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null,
  created_at timestamptz not null default now()
);

create index if not exists report_delivery_actions_scope_idx
  on public.report_delivery_actions (organization_id, user_id, inspection_id, occurred_at desc);

alter table public.inspection_audit_events enable row level security;
alter table public.report_artifacts enable row level security;
alter table public.report_delivery_actions enable row level security;

create policy "inspection_audit_events_select_org_members"
  on public.inspection_audit_events for select
  using (
    auth.uid() is not null
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspection_audit_events.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "inspection_audit_events_insert_org_members"
  on public.inspection_audit_events for insert
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = inspection_audit_events.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "report_artifacts_select_org_members"
  on public.report_artifacts for select
  using (
    auth.uid() is not null
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_artifacts.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "report_artifacts_insert_org_members"
  on public.report_artifacts for insert
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_artifacts.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "report_artifacts_update_org_members"
  on public.report_artifacts for update
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_artifacts.organization_id
        and m.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_artifacts.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "report_delivery_actions_select_org_members"
  on public.report_delivery_actions for select
  using (
    auth.uid() is not null
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_delivery_actions.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "report_delivery_actions_insert_org_members"
  on public.report_delivery_actions for insert
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_delivery_actions.organization_id
        and m.user_id = auth.uid()
    )
  );
