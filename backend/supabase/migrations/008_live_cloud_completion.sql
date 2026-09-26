
-- SmritiAI Phase 30
-- Live cloud completion / compatibility migration

create table if not exists public.memory_people (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  relationship text,
  description text,
  photo_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.memory_media (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.profiles(id) on delete cascade,
  story_id uuid references public.memory_stories(id) on delete set null,
  media_type text not null,
  storage_path text,
  title text,
  caption text,
  created_at timestamptz not null default now()
);

create table if not exists public.rudas_checkpoints (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.profiles(id) on delete cascade,
  completed_game_sessions integer not null default 0,
  assessment_due boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(patient_id)
);

create index if not exists idx_memory_people_patient
  on public.memory_people(patient_id);

create index if not exists idx_memory_media_patient
  on public.memory_media(patient_id);

create index if not exists idx_rudas_checkpoints_patient
  on public.rudas_checkpoints(patient_id);

alter table public.memory_people enable row level security;
alter table public.memory_media enable row level security;
alter table public.rudas_checkpoints enable row level security;

drop policy if exists "memory_people_patient_access"
on public.memory_people;

create policy "memory_people_patient_access"
on public.memory_people
for all
using (
  patient_id = auth.uid()
  or public.is_connected_caregiver(patient_id)
)
with check (
  patient_id = auth.uid()
  or public.is_connected_caregiver(patient_id)
);

drop policy if exists "memory_media_patient_access"
on public.memory_media;

create policy "memory_media_patient_access"
on public.memory_media
for all
using (
  patient_id = auth.uid()
  or public.is_connected_caregiver(patient_id)
)
with check (
  patient_id = auth.uid()
  or public.is_connected_caregiver(patient_id)
);

drop policy if exists "rudas_checkpoint_patient_access"
on public.rudas_checkpoints;

create policy "rudas_checkpoint_patient_access"
on public.rudas_checkpoints
for all
using (
  patient_id = auth.uid()
  or public.is_connected_caregiver(patient_id)
)
with check (
  patient_id = auth.uid()
  or public.is_connected_caregiver(patient_id)
);

-- Ensure private storage buckets.
insert into storage.buckets (id, name, public)
values
  ('memory-photos', 'memory-photos', false),
  ('memory-audio', 'memory-audio', false)
on conflict (id) do update set public = false;

-- Storage access:
-- Files are stored under patient_id/... so RLS can keep each patient's
-- memories private.
drop policy if exists "memory_photo_patient_read"
on storage.objects;

create policy "memory_photo_patient_read"
on storage.objects
for select
using (
  bucket_id = 'memory-photos'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or public.is_connected_caregiver((storage.foldername(name))[1]::uuid)
  )
);

drop policy if exists "memory_photo_patient_insert"
on storage.objects;

create policy "memory_photo_patient_insert"
on storage.objects
for insert
with check (
  bucket_id = 'memory-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "memory_audio_patient_read"
on storage.objects;

create policy "memory_audio_patient_read"
on storage.objects
for select
using (
  bucket_id = 'memory-audio'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or public.is_connected_caregiver((storage.foldername(name))[1]::uuid)
  )
);

drop policy if exists "memory_audio_patient_insert"
on storage.objects;

create policy "memory_audio_patient_insert"
on storage.objects
for insert
with check (
  bucket_id = 'memory-audio'
  and (storage.foldername(name))[1] = auth.uid()::text
);
