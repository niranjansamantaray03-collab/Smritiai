
import 'auth_manager.dart';
import 'auth_user.dart';

class UserContext {
  UserContext._();

  static AuthUser? get currentUser =>
      AuthManager.instance.currentUser;

  static String? get userId =>
      currentUser?.id;

  static String? get role =>
      currentUser?.role;

  static bool get isPatient =>
      currentUser?.role == 'patient';

  static bool get isCaregiver =>
      currentUser?.role == 'caregiver';

  static String? get patientIdForCurrentUser {
    final user = currentUser;

    if (user == null) return null;

    if (user.role == 'patient') {
      return user.id;
    }

    return null;
  }

  static String? patientIdForCaregiver(
    String patientId,
  ) {
    if (!isCaregiver) return null;
    return patientId;
  }
}
