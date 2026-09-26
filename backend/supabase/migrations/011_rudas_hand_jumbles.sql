
CREATE TABLE IF NOT EXISTS public.rudas_hand_jumbles (
  id UUID PRIMARY KEY,
  patient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  assessor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_steps JSONB NOT NULL DEFAULT '[]'::jsonb,
  missed_steps JSONB NOT NULL DEFAULT '[]'::jsonb,
  assessor_notes TEXT NOT NULL DEFAULT '',
  reference_photo_captured BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rudas_hand_jumbles_patient
  ON public.rudas_hand_jumbles(patient_id, completed_at DESC);

ALTER TABLE public.rudas_hand_jumbles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "rudas_hand_jumbles_select" ON public.rudas_hand_jumbles;
DROP POLICY IF EXISTS "rudas_hand_jumbles_insert" ON public.rudas_hand_jumbles;

CREATE POLICY "rudas_hand_jumbles_select"
ON public.rudas_hand_jumbles
FOR SELECT
USING (
  patient_id = auth.uid()
  OR EXISTS (
    SELECT 1
    FROM public.caregiver_patient_connections c
    WHERE c.caregiver_id = auth.uid()
      AND c.patient_id = rudas_hand_jumbles.patient_id
      AND c.status = 'connected'
  )
);

CREATE POLICY "rudas_hand_jumbles_insert"
ON public.rudas_hand_jumbles
FOR INSERT
WITH CHECK (
  assessor_id = auth.uid()
  AND (
    patient_id = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM public.caregiver_patient_connections c
      WHERE c.caregiver_id = auth.uid()
        AND c.patient_id = rudas_hand_jumbles.patient_id
        AND c.status = 'connected'
    )
  )
);
