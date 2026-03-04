alter table public.inspection_media_assets
  add column if not exists requirement_key text,
  add column if not exists media_type text,
  add column if not exists evidence_instance_id text;

update public.inspection_media_assets
set requirement_key = coalesce(requirement_key, 'photo:' || category)
where requirement_key is null;

update public.inspection_media_assets
set media_type = coalesce(media_type, 'photo')
where media_type is null;

update public.inspection_media_assets
set evidence_instance_id = coalesce(evidence_instance_id, requirement_key)
where evidence_instance_id is null;

alter table public.inspection_media_assets
  alter column requirement_key set not null,
  alter column media_type set not null,
  alter column evidence_instance_id set not null;

alter table public.inspection_media_assets
  add constraint inspection_media_assets_media_type_check
    check (media_type in ('photo', 'document'));

do $$
begin
  if exists (
    select 1
    from pg_constraint
    where conname = 'inspection_media_assets_inspection_id_category_key'
      and conrelid = 'public.inspection_media_assets'::regclass
  ) then
    alter table public.inspection_media_assets
      drop constraint inspection_media_assets_inspection_id_category_key;
  end if;
end
$$;

create unique index if not exists inspection_media_assets_requirement_instance_uidx
  on public.inspection_media_assets (
    inspection_id,
    requirement_key,
    evidence_instance_id,
    media_type
  );
