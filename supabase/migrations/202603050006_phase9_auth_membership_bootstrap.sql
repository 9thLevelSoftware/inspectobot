create or replace function public.bootstrap_membership_for_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  existing_org_id uuid;
  bootstrap_org_id uuid;
begin
  select m.organization_id
  into existing_org_id
  from public.organization_memberships m
  where m.user_id = new.id
  order by m.created_at asc
  limit 1;

  if existing_org_id is not null then
    return new;
  end if;

  insert into public.organizations (name)
  values (
    coalesce(nullif(new.raw_user_meta_data ->> 'organization_name', ''), 'InspectoBot Organization')
  )
  returning id into bootstrap_org_id;

  insert into public.organization_memberships (organization_id, user_id, role)
  values (bootstrap_org_id, new.id, 'inspector')
  on conflict (organization_id, user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists auth_user_membership_bootstrap on auth.users;

create trigger auth_user_membership_bootstrap
  after insert on auth.users
  for each row
  execute function public.bootstrap_membership_for_auth_user();
