
-- ============================================================
-- SmritiAI Phase 24
-- Game session idempotency + RUDAS checkpoint
-- ============================================================

-- A game session must be unique.
create unique index if not exists
  game_sessions_unique_id
on public.game_sessions(id);

-- Patient/game history lookup.
create index if not exists
  game_sessions_patient_played_idx
on public.game_sessions(
  patient_id,
  played_at desc
);

-- Seven-session checkpoint.
create table if not exists
public.rudas_checkpoints (
  patient_id uuid primary key,
  completed_game_sessions integer not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.rudas_checkpoints
  enable row level security;

drop policy if exists
  "patient or caregiver reads checkpoint"
on public.rudas_checkpoints;

create policy
  "patient or caregiver reads checkpoint"
on public.rudas_checkpoints
for select
to authenticated
using (
  public.is_patient_owner(patient_id)
  or
  public.is_connected_caregiver_for_patient(patient_id)
);

-- The application should call the server-side function
-- whenever a completed game session is recorded.
--
-- This keeps the seven-session checkpoint separate from
-- the actual RUDAS assessment score.
