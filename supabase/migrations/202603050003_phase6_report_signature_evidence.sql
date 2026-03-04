create table if not exists public.report_signature_evidence (
  id uuid primary key default gen_random_uuid(),
  inspection_id uuid not null references public.inspections(id) on delete cascade,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  signer_role text not null,
  signed_at timestamptz not null,
  signature_hash text not null,
  payload_hash text not null,
  attribution jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (inspection_id, payload_hash, signer_role)
);

create index if not exists report_signature_evidence_scope_idx
  on public.report_signature_evidence (organization_id, user_id, inspection_id);

alter table public.report_signature_evidence enable row level security;

create policy "report_signature_evidence_select_org_members"
  on public.report_signature_evidence for select
  using (
    auth.uid() is not null
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_signature_evidence.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "report_signature_evidence_insert_org_members"
  on public.report_signature_evidence for insert
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_signature_evidence.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "report_signature_evidence_update_org_members"
  on public.report_signature_evidence for update
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_signature_evidence.organization_id
        and m.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_signature_evidence.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy "report_signature_evidence_delete_org_members"
  on public.report_signature_evidence for delete
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_signature_evidence.organization_id
        and m.user_id = auth.uid()
    )
  );
