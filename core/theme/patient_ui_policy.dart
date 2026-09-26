
class PatientUiPolicy {
  PatientUiPolicy._();

  /// Assessment progress must never permanently float over the
  /// dementia-friendly patient interface.
  static const bool showPersistentRudasOverlay = false;

  /// Keep game screens visually calm.
  static const bool showTechnicalGameMetrics = false;

  /// Audio is optional and can be controlled by the patient/caregiver.
  static const bool allowBackgroundMusic = true;
  static const bool allowGameEffects = true;
}
