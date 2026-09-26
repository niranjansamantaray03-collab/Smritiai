
import '../auth/user_context.dart';

class DataAccessGuard {
  DataAccessGuard._();

  static final DataAccessGuard instance =
      DataAccessGuard._();

  bool canAccessPatient(
    String patientId,
  ) {
    if (patientId.isEmpty) return false;

    if (UserContext.isPatient) {
      return UserContext.userId ==
          patientId;
    }

    // Caregiver access must be confirmed
    // by the caregiver-patient connection
    // at the cloud/RLS layer.
    if (UserContext.isCaregiver) {
      return true;
    }

    return false;
  }

  void requirePatientAccess(
    String patientId,
  ) {
    if (!canAccessPatient(patientId)) {
      throw StateError(
        'Unauthorized patient data access.',
      );
    }
  }

  void requireSignedIn() {
    if (UserContext.userId.isEmpty) {
      throw StateError(
        'Authentication required.',
      );
    }
  }
}
