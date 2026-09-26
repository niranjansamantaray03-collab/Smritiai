
import 'user_context.dart';

class FeatureIdentity {
  FeatureIdentity._();

  static Map<String, String> patientScope() => {
    'patient_id': UserContext.userId,
    'user_id': UserContext.userId,
  };

  static Map<String, String> caregiverScope() => {
    'caregiver_id': UserContext.userId,
    'user_id': UserContext.userId,
    'patient_id': UserContext.patientIdForCaregiver,
  };
}
