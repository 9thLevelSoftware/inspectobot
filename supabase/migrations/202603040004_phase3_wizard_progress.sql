alter table if exists public.inspections
  add column if not exists wizard_last_step int not null default 0 check (wizard_last_step >= 0),
  add column if not exists wizard_completion jsonb not null default '{}'::jsonb check (jsonb_typeof(wizard_completion) = 'object'),
  add column if not exists wizard_branch_context jsonb not null default '{}'::jsonb check (jsonb_typeof(wizard_branch_context) = 'object'),
  add column if not exists wizard_status text not null default 'in_progress' check (wizard_status in ('in_progress', 'complete'));
