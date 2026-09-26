
import '../../core/auth/user_context.dart';

class CaregiverContext {
  CaregiverContext._();

  static String get caregiverId => UserContext.userId;

  static String get caregiverName => UserContext.displayName;

  static String get selectedPatientId =>
      UserContext.patientIdForCaregiver;
}
