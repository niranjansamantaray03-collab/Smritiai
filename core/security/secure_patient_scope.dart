
import '../auth/data_access_guard.dart';
import '../auth/user_context.dart';
import 'security_policy.dart';

class SecurePatientScope {
  SecurePatientScope._();

  static final SecurePatientScope instance =
      SecurePatientScope._();

  String resolve({
    String? requestedPatientId,
  }) {
    final currentPatient =
        UserContext.patientIdForCurrentUser;

    final caregiverPatient =
        UserContext.patientIdForCaregiver;

    final requested =
        requestedPatientId?.trim();

    final resolved =
        requested ??
        currentPatient ??
        caregiverPatient;

    if (!SecurityPolicy.validPatientId(resolved)) {
      throw StateError(
        'A valid patient scope is required.',
      );
    }

    DataAccessGuard.instance
        .requirePatientAccess(resolved!);

    return resolved;
  }
}
