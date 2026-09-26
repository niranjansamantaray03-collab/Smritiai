
-- ============================================================
-- SmritiAI Phase 23
-- Memory media metadata + private storage
-- ============================================================

alter table if exists public.memory_photos
  add column if not exists storage_path text;

alter table if exists public.memory_photos
  add column if not exists thumbnail_path text;

alter table if exists public.memory_photos
  add column if not exists uploaded_by uuid;

alter table if exists public.memory_photos
  add column if not exists created_at timestamptz
  default now();

create index if not exists
  memory_photos_patient_idx
on public.memory_photos(patient_id);

-- Private buckets are expected:
--
-- memory-photos
-- memory-audio
--
-- Files should be stored under patient-specific paths:
--
-- memory-photos/{patient_id}/{file}
-- memory-audio/{patient_id}/{file}
--
-- IMPORTANT:
-- Do not make dementia patient media publicly accessible.
-- Use authenticated access / signed URLs.
--
-- Storage policies must verify patient ownership or
-- an active caregiver-patient connection.
