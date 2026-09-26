# SmritiAI Backend

SmritiAI uses a patient-centered data model.

## Core rule

Every patient-owned record contains `patient_id`.

Never use a global "first patient" lookup.

## RUDAS

RUDAS is independent from cognitive games.

- Baseline is created once for a patient.
- Caregiver/authorized assessor records the actual assessment.
- Each reassessment is a separate historical record.
- A completed cognitive-game session increments the checkpoint.
- Every 7 completed sessions makes a reassessment due.
- Games never calculate or diagnose RUDAS.

## Security

Supabase Row Level Security is enabled.

A caregiver can access a patient's protected information only after a
`connected` caregiver-patient relationship exists.

The Android app must only use the Supabase anonymous/public key.

NEVER ship the Supabase `service_role` key inside the Android app.
