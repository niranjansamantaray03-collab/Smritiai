
-- ============================================================
-- SmritiAI Phase 22
-- Authentication + ownership/security hardening
-- ============================================================

-- Profiles are tied directly to Supabase Auth.
alter table if exists public.profiles
  add column if not exists updated_at timestamptz
  default now();

-- Role is constrained to the two application roles.
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'profiles_role_check'
  ) then
    alter table public.profiles
      add constraint profiles_role_check
      check (role in ('patient', 'caregiver'));
  end if;
end $$;

-- A caregiver/patient pair can only have one
-- active connection.
create unique index if not exists
  caregiver_patient_unique_connection
on public.caregiver_patient_connections
(
  caregiver_id,
  patient_id
);

-- Connection status.
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname =
      'caregiver_patient_connection_status_check'
  ) then
    alter table public.caregiver_patient_connections
      add constraint
      caregiver_patient_connection_status_check
      check (
        status in (
          'pending',
          'connected',
          'rejected',
          'revoked'
        )
      );
  end if;
end $$;

-- ============================================================
-- AUTH HELPERS
-- ============================================================

create or replace function
public.current_profile_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role
  from public.profiles
  where id = auth.uid();
$$;

create or replace function
public.is_patient_owner(target_patient uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    auth.uid() = target_patient
    and exists (
      select 1
      from public.profiles p
      where p.id = auth.uid()
        and p.role = 'patient'
    );
$$;

create or replace function
public.is_connected_caregiver_for_patient(
  target_patient uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.caregiver_patient_connections c
    where c.caregiver_id = auth.uid()
      and c.patient_id = target_patient
      and c.status = 'connected'
  );
$$;

-- ============================================================
-- CONNECTION SECURITY
-- ============================================================

alter table public.caregiver_patient_connections
  enable row level security;

drop policy if exists
  "caregiver sees own connections"
on public.caregiver_patient_connections;

create policy
  "caregiver sees own connections"
on public.caregiver_patient_connections
for select
to authenticated
using (
  caregiver_id = auth.uid()
);

drop policy if exists
  "patient sees own connections"
on public.caregiver_patient_connections;

create policy
  "patient sees own connections"
on public.caregiver_patient_connections
for select
to authenticated
using (
  patient_id = auth.uid()
);

-- ============================================================
-- GENERIC PATIENT DATA SECURITY
-- ============================================================

-- These policies intentionally depend on the
-- patient_id column. They should be applied to every
-- patient-owned table.

alter table public.game_sessions
  enable row level security;

alter table public.rudas_assessments
  enable row level security;

alter table public.tasks
  enable row level security;

alter table public.reminders
  enable row level security;

alter table public.memory_stories
  enable row level security;

alter table public.memory_photos
  enable row level security;

alter table public.mood_entries
  enable row level security;

alter table public.story_recall_events
  enable row level security;

-- Game sessions
drop policy if exists
  "patient or connected caregiver reads games"
on public.game_sessions;

create policy
  "patient or connected caregiver reads games"
on public.game_sessions
for select
to authenticated
using (
  public.is_patient_owner(patient_id)
  or
  public.is_connected_caregiver_for_patient(patient_id)
);

-- RUDAS
drop policy if exists
  "patient or connected caregiver reads rudas"
on public.rudas_assessments;

create policy
  "patient or connected caregiver reads rudas"
on public.rudas_assessments
for select
to authenticated
using (
  public.is_patient_owner(patient_id)
  or
  public.is_connected_caregiver_for_patient(patient_id)
);

-- Tasks
drop policy if exists
  "patient or caregiver reads tasks"
on public.tasks;

create policy
  "patient or caregiver reads tasks"
on public.tasks
for select
to authenticated
using (
  public.is_patient_owner(patient_id)
  or
  public.is_connected_caregiver_for_patient(patient_id)
);

-- Reminders
drop policy if exists
  "patient or caregiver reads reminders"
on public.reminders;

create policy
  "patient or caregiver reads reminders"
on public.reminders
for select
to authenticated
using (
  public.is_patient_owner(patient_id)
  or
  public.is_connected_caregiver_for_patient(patient_id)
);

-- Memories
drop policy if exists
  "patient or caregiver reads stories"
on public.memory_stories;

create policy
  "patient or caregiver reads stories"
on public.memory_stories
for select
to authenticated
using (
  public.is_patient_owner(patient_id)
  or
  public.is_connected_caregiver_for_patient(patient_id)
);

-- Mood
drop policy if exists
  "patient or caregiver reads mood"
on public.mood_entries;

create policy
  "patient or caregiver reads mood"
on public.mood_entries
for select
to authenticated
using (
  public.is_patient_owner(patient_id)
  or
  public.is_connected_caregiver_for_patient(patient_id)
);

-- Story recall
drop policy if exists
  "patient or caregiver reads recall"
on public.story_recall_events;

create policy
  "patient or caregiver reads recall"
on public.story_recall_events
for select
to authenticated
using (
  public.is_patient_owner(patient_id)
  or
  public.is_connected_caregiver_for_patient(patient_id)
);

-- ============================================================
-- IMPORTANT
-- ============================================================
--
-- Production INSERT/UPDATE/DELETE policies should be added
-- per table according to the operation:
--
-- Patient:
--   own records only
--
-- Caregiver:
--   records belonging to a connected patient
--
-- Server-side service-role credentials must NEVER be bundled
-- into the Android application.
--
-- The Android app uses the public/anon key only.
-- ============================================================
