insert into storage.buckets (id, name, public)
values ('inspection-media-private', 'inspection-media-private', false)
on conflict (id) do update
set public = excluded.public;

insert into storage.buckets (id, name, public)
values ('report-artifacts-private', 'report-artifacts-private', false)
on conflict (id) do update
set public = excluded.public;

drop policy if exists "inspection_media_private_read" on storage.objects;
create policy "inspection_media_private_read"
  on storage.objects for select
  using (
    auth.uid() is not null
    and bucket_id = 'inspection-media-private'
    and (storage.foldername(name))[1] = 'org'
    and (storage.foldername(name))[3] = 'users'
    and (storage.foldername(name))[4] = auth.uid()::text
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  );

drop policy if exists "inspection_media_private_insert" on storage.objects;
create policy "inspection_media_private_insert"
  on storage.objects for insert
  with check (
    auth.uid() is not null
    and bucket_id = 'inspection-media-private'
    and (storage.foldername(name))[1] = 'org'
    and (storage.foldername(name))[3] = 'users'
    and (storage.foldername(name))[4] = auth.uid()::text
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  );

drop policy if exists "inspection_media_private_update" on storage.objects;
create policy "inspection_media_private_update"
  on storage.objects for update
  using (
    auth.uid() is not null
    and bucket_id = 'inspection-media-private'
    and (storage.foldername(name))[1] = 'org'
    and (storage.foldername(name))[3] = 'users'
    and (storage.foldername(name))[4] = auth.uid()::text
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() is not null
    and bucket_id = 'inspection-media-private'
    and (storage.foldername(name))[1] = 'org'
    and (storage.foldername(name))[3] = 'users'
    and (storage.foldername(name))[4] = auth.uid()::text
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  );

drop policy if exists "inspection_media_private_delete" on storage.objects;
create policy "inspection_media_private_delete"
  on storage.objects for delete
  using (
    auth.uid() is not null
    and bucket_id = 'inspection-media-private'
    and (storage.foldername(name))[1] = 'org'
    and (storage.foldername(name))[3] = 'users'
    and (storage.foldername(name))[4] = auth.uid()::text
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  );

drop policy if exists "report_artifacts_private_read" on storage.objects;
create policy "report_artifacts_private_read"
  on storage.objects for select
  using (
    auth.uid() is not null
    and bucket_id = 'report-artifacts-private'
    and (storage.foldername(name))[1] = 'org'
    and (storage.foldername(name))[3] = 'users'
    and (storage.foldername(name))[4] = auth.uid()::text
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  );

drop policy if exists "report_artifacts_private_insert" on storage.objects;
create policy "report_artifacts_private_insert"
  on storage.objects for insert
  with check (
    auth.uid() is not null
    and bucket_id = 'report-artifacts-private'
    and (storage.foldername(name))[1] = 'org'
    and (storage.foldername(name))[3] = 'users'
    and (storage.foldername(name))[4] = auth.uid()::text
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  );

drop policy if exists "report_artifacts_private_update" on storage.objects;
create policy "report_artifacts_private_update"
  on storage.objects for update
  using (
    auth.uid() is not null
    and bucket_id = 'report-artifacts-private'
    and (storage.foldername(name))[1] = 'org'
    and (storage.foldername(name))[3] = 'users'
    and (storage.foldername(name))[4] = auth.uid()::text
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() is not null
    and bucket_id = 'report-artifacts-private'
    and (storage.foldername(name))[1] = 'org'
    and (storage.foldername(name))[3] = 'users'
    and (storage.foldername(name))[4] = auth.uid()::text
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  );

drop policy if exists "report_artifacts_private_delete" on storage.objects;
create policy "report_artifacts_private_delete"
  on storage.objects for delete
  using (
    auth.uid() is not null
    and bucket_id = 'report-artifacts-private'
    and (storage.foldername(name))[1] = 'org'
    and (storage.foldername(name))[3] = 'users'
    and (storage.foldername(name))[4] = auth.uid()::text
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  );
