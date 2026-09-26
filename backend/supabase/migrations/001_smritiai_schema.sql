-- ============================================================
-- SMRITIAI DATABASE
-- Dementia Care Companion
-- Version 1.0.0
-- ============================================================

create extension if not exists pgcrypto;

-- ------------------------------------------------------------
-- PROFILES
-- ------------------------------------------------------------

create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    role text not null check (role in ('patient', 'caregiver')),
    full_name text not null,
    email text,
    language text not null default 'en'
        check (language in ('en', 'hi', 'mr')),
    avatar_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- CAREGIVER / PATIENT CONNECTIONS
-- ------------------------------------------------------------

create table if not exists public.caregiver_patient_connections (
    id uuid primary key default gen_random_uuid(),
    caregiver_id uuid not null references public.profiles(id) on delete cascade,
    patient_id uuid not null references public.profiles(id) on delete cascade,
    status text not null default 'pending'
        check (status in ('pending', 'connected', 'rejected', 'revoked')),
    requested_by uuid not null references public.profiles(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    unique(caregiver_id, patient_id)
);

-- ------------------------------------------------------------
-- RUDAS ASSESSMENTS
-- ------------------------------------------------------------

create table if not exists public.rudas_assessments (
    id uuid primary key default gen_random_uuid(),
    patient_id uuid not null references public.profiles(id) on delete cascade,
    assessor_id uuid references public.profiles(id),
    assessment_type text not null default 'baseline'
        check (assessment_type in ('baseline', 'reassessment')),
    memory integer not null default 0 check (memory between 0 and 8),
    orientation integer not null default 0 check (orientation between 0 and 5),
    praxis integer not null default 0 check (praxis between 0 and 2),
    visuoconstruction integer not null default 0
        check (visuoconstruction between 0 and 3),
    judgment integer not null default 0 check (judgment between 0 and 4),
    language integer not null default 0 check (language between 0 and 8),
    total integer generated always as (
        memory +
        orientation +
        praxis +
        visuoconstruction +
        judgment +
        language
    ) stored,
    notes text,
    assessed_at timestamptz not null default now(),
    created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- GAME SESSIONS
-- ------------------------------------------------------------

create table if not exists public.game_sessions (
    id uuid primary key default gen_random_uuid(),
    patient_id uuid not null references public.profiles(id) on delete cascade,
    game_id text not null,
    game_name text not null,
    score integer not null default 0,
    max_score integer not null default 0,
    correct_answers integer not null default 0,
    total_questions integer not null default 0,
    duration_seconds integer not null default 0,
    completed boolean not null default false,
    played_at timestamptz not null default now(),
    created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- TASKS
-- ------------------------------------------------------------

create table if not exists public.tasks (
    id uuid primary key default gen_random_uuid(),
    patient_id uuid not null references public.profiles(id) on delete cascade,
    caregiver_id uuid not null references public.profiles(id) on delete cascade,
    title text not null,
    description text,
    due_at timestamptz,
    completed boolean not null default false,
    completed_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- REMINDERS
-- ------------------------------------------------------------

create table if not exists public.reminders (
    id uuid primary key default gen_random_uuid(),
    patient_id uuid not null references public.profiles(id) on delete cascade,
    caregiver_id uuid references public.profiles(id) on delete set null,
    title text not null,
    description text,
    scheduled_at timestamptz not null,
    repeat_rule text,
    enabled boolean not null default true,
    completed boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- MEMORY STORIES
-- ------------------------------------------------------------

create table if not exists public.memory_stories (
    id uuid primary key default gen_random_uuid(),
    patient_id uuid not null references public.profiles(id) on delete cascade,
    created_by uuid references public.profiles(id) on delete set null,
    title text not null,
    story text not null,
    image_url text,
    audio_url text,
    tags text[] not null default '{}',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- MEMORY PHOTOS
-- ------------------------------------------------------------

create table if not exists public.memory_photos (
    id uuid primary key default gen_random_uuid(),
    patient_id uuid not null references public.profiles(id) on delete cascade,
    created_by uuid references public.profiles(id) on delete set null,
    title text not null,
    image_url text not null,
    description text,
    captured_date date,
    people text[] not null default '{}',
    location text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- MOOD
-- ------------------------------------------------------------

create table if not exists public.mood_entries (
    id uuid primary key default gen_random_uuid(),
    patient_id uuid not null references public.profiles(id) on delete cascade,
    mood text not null,
    note text,
    created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- STORY RECALL
-- IMPORTANT: separate from RUDAS scoring
-- ------------------------------------------------------------

create table if not exists public.story_recall_events (
    id uuid primary key default gen_random_uuid(),
    patient_id uuid not null references public.profiles(id) on delete cascade,
    story_id uuid not null references public.memory_stories(id) on delete cascade,
    recall_type text not null
        check (recall_type in ('independent', 'cued')),
    response text,
    recorded_by uuid references public.profiles(id) on delete set null,
    created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- RUDAS CHECKPOINTS
-- Seven completed game sessions -> reassessment due
-- ------------------------------------------------------------

create table if not exists public.rudas_checkpoints (
    id uuid primary key default gen_random_uuid(),
    patient_id uuid not null references public.profiles(id) on delete cascade,
    completed_game_sessions integer not null default 0,
    checkpoint_number integer not null default 1,
    assessment_due boolean not null default false,
    last_assessment_id uuid references public.rudas_assessments(id)
        on delete set null,
    updated_at timestamptz not null default now(),

    unique(patient_id)
);

-- ------------------------------------------------------------
-- INDEXES
-- ------------------------------------------------------------

create index if not exists idx_connections_patient
    on public.caregiver_patient_connections(patient_id);

create index if not exists idx_connections_caregiver
    on public.caregiver_patient_connections(caregiver_id);

create index if not exists idx_rudas_patient
    on public.rudas_assessments(patient_id, assessed_at desc);

create index if not exists idx_games_patient
    on public.game_sessions(patient_id, played_at desc);

create index if not exists idx_tasks_patient
    on public.tasks(patient_id, due_at);

create index if not exists idx_reminders_patient
    on public.reminders(patient_id, scheduled_at);

create index if not exists idx_stories_patient
    on public.memory_stories(patient_id);

create index if not exists idx_photos_patient
    on public.memory_photos(patient_id);

create index if not exists idx_mood_patient
    on public.mood_entries(patient_id, created_at desc);

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

create or replace function public.is_connected_caregiver(
    target_patient uuid
)
returns boolean
language sql
security definer
stable
as $$
    select exists (
        select 1
        from public.caregiver_patient_connections c
        where c.caregiver_id = auth.uid()
          and c.patient_id = target_patient
          and c.status = 'connected'
    );
$$;

create or replace function public.is_connected_patient(
    target_caregiver uuid
)
returns boolean
language sql
security definer
stable
as $$
    select exists (
        select 1
        from public.caregiver_patient_connections c
        where c.patient_id = auth.uid()
          and c.caregiver_id = target_caregiver
          and c.status = 'connected'
    );
$$;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

alter table public.profiles enable row level security;
alter table public.caregiver_patient_connections enable row level security;
alter table public.rudas_assessments enable row level security;
alter table public.game_sessions enable row level security;
alter table public.tasks enable row level security;
alter table public.reminders enable row level security;
alter table public.memory_stories enable row level security;
alter table public.memory_photos enable row level security;
alter table public.mood_entries enable row level security;
alter table public.story_recall_events enable row level security;
alter table public.rudas_checkpoints enable row level security;

-- ------------------------------------------------------------
-- PROFILES
-- ------------------------------------------------------------

create policy "profiles own profile"
on public.profiles
for select
using (
    id = auth.uid()
    or public.is_connected_caregiver(id)
    or public.is_connected_patient(id)
);

create policy "profiles create own"
on public.profiles
for insert
with check (id = auth.uid());

create policy "profiles update own"
on public.profiles
for update
using (id = auth.uid())
with check (id = auth.uid());

-- ------------------------------------------------------------
-- CONNECTIONS
-- ------------------------------------------------------------

create policy "connection participants read"
on public.caregiver_patient_connections
for select
using (
    caregiver_id = auth.uid()
    or patient_id = auth.uid()
);

create policy "connection participant create"
on public.caregiver_patient_connections
for insert
with check (
    requested_by = auth.uid()
    and (
        caregiver_id = auth.uid()
        or patient_id = auth.uid()
    )
);

create policy "connection participants update"
on public.caregiver_patient_connections
for update
using (
    caregiver_id = auth.uid()
    or patient_id = auth.uid()
)
with check (
    caregiver_id = auth.uid()
    or patient_id = auth.uid()
);

-- ------------------------------------------------------------
-- RUDAS
-- ------------------------------------------------------------

create policy "patient or caregiver read rudas"
on public.rudas_assessments
for select
using (
    patient_id = auth.uid()
    or assessor_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

create policy "authorized assessor insert rudas"
on public.rudas_assessments
for insert
with check (
    assessor_id = auth.uid()
    and (
        patient_id = auth.uid()
        or public.is_connected_caregiver(patient_id)
    )
);

create policy "authorized assessor update rudas"
on public.rudas_assessments
for update
using (
    assessor_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
)
with check (
    assessor_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

-- ------------------------------------------------------------
-- GAME SESSIONS
-- ------------------------------------------------------------

create policy "patient or caregiver read games"
on public.game_sessions
for select
using (
    patient_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

create policy "patient create games"
on public.game_sessions
for insert
with check (patient_id = auth.uid());

-- ------------------------------------------------------------
-- TASKS
-- ------------------------------------------------------------

create policy "task participants read"
on public.tasks
for select
using (
    patient_id = auth.uid()
    or caregiver_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

create policy "caregiver create tasks"
on public.tasks
for insert
with check (
    caregiver_id = auth.uid()
    and public.is_connected_caregiver(patient_id)
);

create policy "task participants update"
on public.tasks
for update
using (
    patient_id = auth.uid()
    or caregiver_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

create policy "caregiver delete tasks"
on public.tasks
for delete
using (
    caregiver_id = auth.uid()
);

-- ------------------------------------------------------------
-- REMINDERS
-- ------------------------------------------------------------

create policy "reminder participants read"
on public.reminders
for select
using (
    patient_id = auth.uid()
    or caregiver_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

create policy "caregiver create reminders"
on public.reminders
for insert
with check (
    caregiver_id = auth.uid()
    and public.is_connected_caregiver(patient_id)
);

create policy "reminder participants update"
on public.reminders
for update
using (
    patient_id = auth.uid()
    or caregiver_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

-- ------------------------------------------------------------
-- MEMORY STORIES
-- ------------------------------------------------------------

create policy "memory story participants read"
on public.memory_stories
for select
using (
    patient_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

create policy "caregiver create memory story"
on public.memory_stories
for insert
with check (
    created_by = auth.uid()
    and public.is_connected_caregiver(patient_id)
);

create policy "caregiver update memory story"
on public.memory_stories
for update
using (
    public.is_connected_caregiver(patient_id)
);

create policy "caregiver delete memory story"
on public.memory_stories
for delete
using (
    public.is_connected_caregiver(patient_id)
);

-- ------------------------------------------------------------
-- MEMORY PHOTOS
-- ------------------------------------------------------------

create policy "memory photo participants read"
on public.memory_photos
for select
using (
    patient_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

create policy "caregiver create memory photo"
on public.memory_photos
for insert
with check (
    created_by = auth.uid()
    and public.is_connected_caregiver(patient_id)
);

create policy "caregiver update memory photo"
on public.memory_photos
for update
using (
    public.is_connected_caregiver(patient_id)
);

create policy "caregiver delete memory photo"
on public.memory_photos
for delete
using (
    public.is_connected_caregiver(patient_id)
);

-- ------------------------------------------------------------
-- MOOD
-- ------------------------------------------------------------

create policy "mood participants read"
on public.mood_entries
for select
using (
    patient_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

create policy "patient create mood"
on public.mood_entries
for insert
with check (
    patient_id = auth.uid()
);

-- ------------------------------------------------------------
-- STORY RECALL
-- ------------------------------------------------------------

create policy "story recall participants read"
on public.story_recall_events
for select
using (
    patient_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

create policy "patient create story recall"
on public.story_recall_events
for insert
with check (
    patient_id = auth.uid()
);

-- ------------------------------------------------------------
-- RUDAS CHECKPOINTS
-- ------------------------------------------------------------

create policy "checkpoint participants read"
on public.rudas_checkpoints
for select
using (
    patient_id = auth.uid()
    or public.is_connected_caregiver(patient_id)
);

create policy "patient checkpoint create"
on public.rudas_checkpoints
for insert
with check (
    patient_id = auth.uid()
);

create policy "patient checkpoint update"
on public.rudas_checkpoints
for update
using (
    patient_id = auth.uid()
);

-- ============================================================
-- STORAGE
-- ============================================================

insert into storage.buckets (id, name, public)
values
    ('memory-photos', 'memory-photos', false),
    ('memory-audio', 'memory-audio', false)
on conflict (id) do nothing;

-- ============================================================
-- AUTO PROFILE CREATION
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.profiles (
        id,
        role,
        full_name,
        email,
        language
    )
    values (
        new.id,
        coalesce(new.raw_user_meta_data->>'role', 'patient'),
        coalesce(new.raw_user_meta_data->>'full_name', 'SmritiAI User'),
        new.email,
        coalesce(new.raw_user_meta_data->>'language', 'en')
    );

    return new;
end;
$$;

drop trigger if exists on_auth_user_created
on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute procedure public.handle_new_user();

-- ============================================================
-- RUDAS CHECKPOINT FUNCTION
-- Seven COMPLETED sessions only
-- ============================================================

create or replace function public.record_completed_game_session(
    target_patient uuid
)
returns public.rudas_checkpoints
language plpgsql
security definer
set search_path = public
as $$
declare
    checkpoint public.rudas_checkpoints;
begin
    if auth.uid() <> target_patient then
        raise exception 'Only the patient can record their own game session';
    end if;

    insert into public.rudas_checkpoints (
        patient_id,
        completed_game_sessions,
        checkpoint_number,
        assessment_due
    )
    values (
        target_patient,
        1,
        1,
        false
    )
    on conflict (patient_id)
    do update set
        completed_game_sessions =
            public.rudas_checkpoints.completed_game_sessions + 1,
        assessment_due =
            (
                (public.rudas_checkpoints.completed_game_sessions + 1) % 7 = 0
            ),
        checkpoint_number =
            case
                when (
                    (public.rudas_checkpoints.completed_game_sessions + 1) % 7 = 0
                )
                then public.rudas_checkpoints.checkpoint_number + 1
                else public.rudas_checkpoints.checkpoint_number
            end,
        updated_at = now()
    returning * into checkpoint;

    return checkpoint;
end;
$$;
