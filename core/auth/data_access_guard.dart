
import 'user_context.dart';
import '../security/access_check.dart';
import '../security/security_policy.dart';

class DataAccessGuard {
  DataAccessGuard._();

  static final DataAccessGuard instance =
      DataAccessGuard._();

  AccessCheck canAccessPatient(
    String patientId,
  ) {
    if (!SecurityPolicy.validPatientId(patientId)) {
      return const AccessCheck.deny(
        'Invalid patient identity.',
      );
    }

    final currentUser =
        UserContext.userId;

    if (currentUser == null ||
        currentUser.trim().isEmpty) {
      return const AccessCheck.deny(
        'No authenticated user.',
      );
    }

    final ownPatient =
        UserContext.patientIdForCurrentUser;

    if (ownPatient == patientId) {
      return const AccessCheck.allow();
    }

    final caregiverPatient =
        UserContext.patientIdForCaregiver;

    if (caregiverPatient == patientId) {
      return const AccessCheck.allow();
    }

    return const AccessCheck.deny(
      'Patient is not connected to the current user.',
    );
  }

  void requirePatientAccess(
    String patientId,
  ) {
    final result =
        canAccessPatient(patientId);

    if (!result.allowed) {
      throw StateError(result.reason);
    }
  }
}
