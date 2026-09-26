
-- ============================================================
-- SmritiAI Phase 35
-- Patient connection codes
-- ============================================================

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS patient_connection_code TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS
profiles_patient_connection_code_unique
ON public.profiles(patient_connection_code)
WHERE patient_connection_code IS NOT NULL;

-- Generate a short, human-friendly connection code.
CREATE OR REPLACE FUNCTION public.ensure_patient_connection_code(
  target_patient UUID
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  existing_code TEXT;
  new_code TEXT;
  attempts INTEGER := 0;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF auth.uid() <> target_patient THEN
    RAISE EXCEPTION 'Only the patient can generate their connection code';
  END IF;

  SELECT patient_connection_code
  INTO existing_code
  FROM public.profiles
  WHERE id = target_patient
    AND role = 'patient';

  IF existing_code IS NOT NULL THEN
    RETURN existing_code;
  END IF;

  LOOP
    attempts := attempts + 1;

    new_code :=
      UPPER(
        SUBSTRING(
          REPLACE(gen_random_uuid()::TEXT, '-', '')
          FROM 1 FOR 8
        )
      );

    BEGIN
      UPDATE public.profiles
      SET patient_connection_code = new_code
      WHERE id = target_patient
        AND role = 'patient'
        AND patient_connection_code IS NULL;

      IF FOUND THEN
        RETURN new_code;
      END IF;

      SELECT patient_connection_code
      INTO existing_code
      FROM public.profiles
      WHERE id = target_patient;

      IF existing_code IS NOT NULL THEN
        RETURN existing_code;
      END IF;

    EXCEPTION
      WHEN unique_violation THEN
        NULL;
    END;

    IF attempts >= 10 THEN
      RAISE EXCEPTION 'Unable to generate connection code';
    END IF;
  END LOOP;
END;
$$;

-- Caregiver connects using the patient's code.
CREATE OR REPLACE FUNCTION public.connect_caregiver_by_patient_code(
  connection_code TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  patient_uuid UUID;
  caregiver_uuid UUID;
BEGIN
  caregiver_uuid := auth.uid();

  IF caregiver_uuid IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  SELECT id
  INTO patient_uuid
  FROM public.profiles
  WHERE role = 'patient'
    AND patient_connection_code =
      UPPER(TRIM(connection_code))
  LIMIT 1;

  IF patient_uuid IS NULL THEN
    RAISE EXCEPTION 'Patient connection code not found';
  END IF;

  IF patient_uuid = caregiver_uuid THEN
    RAISE EXCEPTION 'A patient cannot connect to themselves';
  END IF;

  INSERT INTO public.caregiver_patient_connections
    (caregiver_id, patient_id, status)
  VALUES
    (caregiver_uuid, patient_uuid, 'connected')
  ON CONFLICT (caregiver_id, patient_id)
  DO UPDATE SET status = 'connected';

  RETURN patient_uuid;
END;
$$;

REVOKE ALL ON FUNCTION
public.ensure_patient_connection_code(UUID)
FROM PUBLIC;

GRANT EXECUTE ON FUNCTION
public.ensure_patient_connection_code(UUID)
TO authenticated;

REVOKE ALL ON FUNCTION
public.connect_caregiver_by_patient_code(TEXT)
FROM PUBLIC;

GRANT EXECUTE ON FUNCTION
public.connect_caregiver_by_patient_code(TEXT)
TO authenticated;

COMMENT ON COLUMN public.profiles.patient_connection_code IS
'Private patient-to-caregiver connection code.';

COMMENT ON FUNCTION public.ensure_patient_connection_code(UUID) IS
'Creates an idempotent connection code for the authenticated patient.';

COMMENT ON FUNCTION public.connect_caregiver_by_patient_code(TEXT) IS
'Connects the authenticated caregiver to a patient using the patient connection code.';
