insert into storage.buckets (id, name, public)
values ('signature-private', 'signature-private', false)
on conflict (id) do update
set public = excluded.public;

create policy "signature_private_read"
  on storage.objects for select
  using (
    auth.uid() is not null
    and bucket_id = 'signature-private'
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  );

create policy "signature_private_insert"
  on storage.objects for insert
  with check (
    auth.uid() is not null
    and bucket_id = 'signature-private'
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

create policy "signature_private_update"
  on storage.objects for update
  using (
    auth.uid() is not null
    and bucket_id = 'signature-private'
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() is not null
    and bucket_id = 'signature-private'
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  );

create policy "signature_private_delete"
  on storage.objects for delete
  using (
    auth.uid() is not null
    and bucket_id = 'signature-private'
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id::text = (storage.foldername(name))[2]
        and m.user_id = auth.uid()
    )
  );
