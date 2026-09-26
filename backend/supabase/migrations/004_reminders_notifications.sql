
-- SmritiAI Phase 21
-- Reminder scheduling metadata

alter table if exists public.reminders
  add column if not exists kind text
    default 'custom';

alter table if exists public.reminders
  add column if not exists enabled boolean
    default true;

alter table if exists public.reminders
  add column if not exists updated_at timestamptz
    default now();

alter table if exists public.reminders
  add column if not exists timezone text
    default 'Asia/Kolkata';

create index if not exists
  reminders_patient_enabled_idx
on public.reminders(patient_id, enabled);

create index if not exists
  reminders_scheduled_at_idx
on public.reminders(scheduled_at);

-- Keep notification scheduling data separate from
-- clinical assessment data.
--
-- The Android client remains responsible for requesting
-- notification permission and scheduling local notifications.
