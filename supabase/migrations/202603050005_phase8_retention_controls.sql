alter table public.report_artifacts
  add column if not exists retain_until timestamptz not null
  default (now() + interval '5 years');

create or replace function public.enforce_report_artifact_retention_floor()
returns trigger
language plpgsql
as $$
begin
  if new.retain_until < new.created_at + interval '5 years' then
    raise exception 'retain_until must be at least 5 years from created_at';
  end if;
  return new;
end;
$$;

drop trigger if exists report_artifacts_retention_floor on public.report_artifacts;
create trigger report_artifacts_retention_floor
before insert or update on public.report_artifacts
for each row
execute function public.enforce_report_artifact_retention_floor();

create or replace function public.prevent_artifact_delete_before_retention()
returns trigger
language plpgsql
as $$
begin
  if old.retain_until > now() then
    raise exception 'report artifact cannot be deleted before retain_until';
  end if;
  return old;
end;
$$;

drop trigger if exists report_artifacts_retention_delete_guard on public.report_artifacts;
create trigger report_artifacts_retention_delete_guard
before delete on public.report_artifacts
for each row
execute function public.prevent_artifact_delete_before_retention();

create policy "report_artifacts_delete_after_retention_org_members"
  on public.report_artifacts for delete
  using (
    auth.uid() is not null
    and user_id = auth.uid()
    and retain_until <= now()
    and exists (
      select 1
      from public.organization_memberships m
      where m.organization_id = report_artifacts.organization_id
        and m.user_id = auth.uid()
    )
  );

create or replace function public.retention_cleanup_expired_artifacts()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  deleted_count integer;
begin
  delete from public.report_artifacts
  where retain_until <= now();

  get diagnostics deleted_count = row_count;
  return deleted_count;
end;
$$;

create extension if not exists pg_cron;

do $$
begin
  if not exists (
    select 1 from cron.job where jobname = 'retention_cleanup_expired_artifacts_daily'
  ) then
    perform cron.schedule(
      'retention_cleanup_expired_artifacts_daily',
      '0 3 * * *',
      'select public.retention_cleanup_expired_artifacts();'
    );
  end if;
end;
$$;
