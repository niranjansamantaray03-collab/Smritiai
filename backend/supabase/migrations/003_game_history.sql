
-- SmritiAI Phase 16
-- Cognitive game history.
-- Run after migrations 001 and 002.

create table if not exists public.game_sessions (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.profiles(id) on delete cascade,
  game_id text not null,
  game_name text not null,
  played_at timestamptz not null default now(),
  score integer not null default 0,
  max_score integer not null default 0,
  correct_answers integer not null default 0,
  total_questions integer not null default 0,
  duration_seconds integer not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists idx_game_sessions_patient_date
  on public.game_sessions(patient_id, played_at desc);

create index if not exists idx_game_sessions_patient_game
  on public.game_sessions(patient_id, game_id);

alter table public.game_sessions enable row level security;

-- The exact caregiver/patient access model is inherited from the
-- connection helper established in migration 001.
-- These policies intentionally keep game history patient scoped.

drop policy if exists "patients read own game sessions"
on public.game_sessions;

create policy "patients read own game sessions"
on public.game_sessions
for select
using (auth.uid() = patient_id);

drop policy if exists "caregivers read connected game sessions"
on public.game_sessions;

create policy "caregivers read connected game sessions"
on public.game_sessions
for select
using (
  exists (
    select 1
    from public.caregiver_patient_connections c
    where c.patient_id = game_sessions.patient_id
      and c.caregiver_id = auth.uid()
      and c.status = 'connected'
  )
);

-- Inserts should be performed by the authenticated patient/app
-- through the production repository after Supabase Auth is connected.
