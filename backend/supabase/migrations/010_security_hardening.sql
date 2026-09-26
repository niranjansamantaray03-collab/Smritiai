
-- ============================================================
-- SmritiAI Phase 43
-- Security / RLS / data isolation hardening
-- ============================================================

-- Enable RLS on all patient-owned application tables.
ALTER TABLE IF EXISTS public.profiles
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.caregiver_patient_connections
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.rudas_assessments
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.game_sessions
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.tasks
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.reminders
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.memory_stories
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.memory_people
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.memory_media
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.memory_photos
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.mood_entries
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.story_recall_events
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public.rudas_checkpoints
  ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------
-- Helper: authenticated user must exist.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.is_authenticated_user(
  target_user UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth.uid() = target_user;
$$;

-- ------------------------------------------------------------
-- Helper: patient ownership.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.is_patient_owner(
  target_patient UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.id = target_patient
      AND p.id = auth.uid()
      AND p.role = 'patient'
  );
$$;

-- ------------------------------------------------------------
-- Helper: connected caregiver.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.is_connected_caregiver(
  target_patient UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.caregiver_patient_connections c
    WHERE c.caregiver_id = auth.uid()
      AND c.patient_id = target_patient
      AND COALESCE(c.status, 'connected') = 'connected'
  );
$$;

-- ------------------------------------------------------------
-- Patient-owned records:
-- patient can access own data
-- connected caregiver can access connected patient's data
-- ------------------------------------------------------------

DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOREACH tbl IN ARRAY ARRAY[
    'rudas_assessments',
    'game_sessions',
    'tasks',
    'reminders',
    'memory_stories',
    'memory_people',
    'memory_media',
    'memory_photos',
    'mood_entries',
    'story_recall_events',
    'rudas_checkpoints'
  ]
  LOOP
    EXECUTE format(
      'DROP POLICY IF EXISTS "smritiai_patient_or_caregiver_%s" ON public.%I',
      tbl,
      tbl
    );

    EXECUTE format(
      'CREATE POLICY "smritiai_patient_or_caregiver_%s"
       ON public.%I
       FOR ALL
       TO authenticated
       USING (
         public.is_patient_owner(patient_id)
         OR public.is_connected_caregiver(patient_id)
       )
       WITH CHECK (
         public.is_patient_owner(patient_id)
         OR public.is_connected_caregiver(patient_id)
       )',
      tbl,
      tbl
    );
  END LOOP;
END
$$;

-- ------------------------------------------------------------
-- Profiles:
-- user can read/update own profile.
-- Caregiver may read connected patient profile.
-- ------------------------------------------------------------

DROP POLICY IF EXISTS "smritiai_profile_self_or_connection"
ON public.profiles;

CREATE POLICY "smritiai_profile_self_or_connection"
ON public.profiles
FOR SELECT
TO authenticated
USING (
  id = auth.uid()
  OR (
    role = 'patient'
    AND public.is_connected_caregiver(id)
  )
);

DROP POLICY IF EXISTS "smritiai_profile_self_update"
ON public.profiles;

CREATE POLICY "smritiai_profile_self_update"
ON public.profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- ------------------------------------------------------------
-- Connections:
-- caregiver can see own connection rows.
-- patient can see rows connected to their own patient account.
-- ------------------------------------------------------------

DROP POLICY IF EXISTS "smritiai_connections_owner"
ON public.caregiver_patient_connections;

CREATE POLICY "smritiai_connections_owner"
ON public.caregiver_patient_connections
FOR SELECT
TO authenticated
USING (
  caregiver_id = auth.uid()
  OR patient_id = auth.uid()
);

-- ------------------------------------------------------------
-- Prevent arbitrary connection manipulation through direct
-- table writes. Connection functions should be used.
-- ------------------------------------------------------------

DROP POLICY IF EXISTS "smritiai_connections_insert"
ON public.caregiver_patient_connections;

DROP POLICY IF EXISTS "smritiai_connections_update"
ON public.caregiver_patient_connections;

DROP POLICY IF EXISTS "smritiai_connections_delete"
ON public.caregiver_patient_connections;

-- ------------------------------------------------------------
-- Private storage:
-- object path must start with authenticated patient's UUID.
-- Caregiver access is validated through connection.
-- ------------------------------------------------------------

DROP POLICY IF EXISTS "smritiai_memory_objects_read"
ON storage.objects;

CREATE POLICY "smritiai_memory_objects_read"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id IN ('memory-photos', 'memory-audio')
  AND (
    owner_id = auth.uid()::text
    OR public.is_connected_caregiver(
      (storage.foldername(name))[1]::uuid
    )
  )
);

DROP POLICY IF EXISTS "smritiai_memory_objects_insert"
ON storage.objects;

CREATE POLICY "smritiai_memory_objects_insert"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id IN ('memory-photos', 'memory-audio')
  AND (
    owner_id = auth.uid()::text
    OR public.is_patient_owner(
      (storage.foldername(name))[1]::uuid
    )
  )
);

DROP POLICY IF EXISTS "smritiai_memory_objects_update"
ON storage.objects;

CREATE POLICY "smritiai_memory_objects_update"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  owner_id = auth.uid()::text
)
WITH CHECK (
  owner_id = auth.uid()::text
);

DROP POLICY IF EXISTS "smritiai_memory_objects_delete"
ON storage.objects;

CREATE POLICY "smritiai_memory_objects_delete"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  owner_id = auth.uid()::text
);

-- ------------------------------------------------------------
-- Useful indexes.
-- ------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_game_sessions_patient_created
ON public.game_sessions(patient_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_rudas_assessments_patient_date
ON public.rudas_assessments(patient_id, date DESC);

CREATE INDEX IF NOT EXISTS idx_tasks_patient_due
ON public.tasks(patient_id, due_at);

CREATE INDEX IF NOT EXISTS idx_reminders_patient_enabled
ON public.reminders(patient_id, enabled);

CREATE INDEX IF NOT EXISTS idx_memory_media_patient_created
ON public.memory_media(patient_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_mood_entries_patient_created
ON public.mood_entries(patient_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_story_recall_patient_created
ON public.story_recall_events(patient_id, created_at DESC);
