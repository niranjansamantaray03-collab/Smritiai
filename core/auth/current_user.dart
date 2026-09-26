
import 'auth_manager.dart';
import 'auth_user.dart';

class CurrentUser {
  CurrentUser._();

  static AuthUser? get user =>
      AuthManager.instance.session.currentUser;

  static String get id =>
      AuthManager.instance.session.userId ?? 'current_patient';

  static String get name =>
      user?.name ?? 'Patient';

  static bool get isPatient =>
      user?.role == AuthRole.patient;

  static bool get isCaregiver =>
      user?.role == AuthRole.caregiver;
}
