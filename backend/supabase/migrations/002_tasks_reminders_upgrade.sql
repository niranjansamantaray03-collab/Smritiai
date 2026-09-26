
-- SmritiAI Phase 15
-- Task + reminder persistence upgrade.
-- Run after 001_smritiai_schema.sql in the real Supabase project.

alter table public.tasks
  add column if not exists priority text not null default 'normal',
  add column if not exists category text not null default 'general',
  add column if not exists created_at timestamptz not null default now();

alter table public.reminders
  add column if not exists description text not null default '',
  add column if not exists repeat_type text not null default 'none',
  add column if not exists enabled boolean not null default true,
  add column if not exists created_at timestamptz not null default now();

create index if not exists idx_tasks_patient_due
  on public.tasks(patient_id, due_at);

create index if not exists idx_tasks_patient_completed
  on public.tasks(patient_id, completed);

create index if not exists idx_reminders_patient_scheduled
  on public.reminders(patient_id, scheduled_at);

create index if not exists idx_reminders_patient_enabled
  on public.reminders(patient_id, enabled);

-- Task access remains patient/caregiver scoped through the
-- connection policies established in migration 001.

-- IMPORTANT:
-- Android notification scheduling is performed by the application.
-- The database stores the authoritative reminder definition.
