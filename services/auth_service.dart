
import '../features/onboarding/services/patient_onboarding_service.dart';

import '../core/auth/auth_manager.dart';
import '../core/auth/auth_session.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Future<AuthSession?> login(
    String email,
    String password,
  ) {
    return AuthManager.instance.login(
      email,
      password,
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String language = 'en',
  }) {
    return AuthManager.instance.register(
      name: name,
      email: email,
      password: password,
      role: role,
      language: language,
    );
  }

  Future<void> logout() {
    return AuthManager.instance.logout();
  }

  Future<AuthSession?> restoreSession() {
    return AuthManager.instance.restoreSession();
  }


  Future<dynamic> registerPatientAndInitialize({
    required String name,
    required String email,
    required String password,
    required String language,
  }) async {
    final result = await register(
      name: name,
      email: email,
      password: password,
      role: 'patient',
      language: language,
    );

    // Different AuthService implementations may return a user/session
    // object. We intentionally avoid assuming its concrete type here.
    final dynamic value = result;

    String? patientId;
    try {
      patientId = value?.user?.id?.toString();
    } catch (_) {}

    try {
      patientId ??= value?.id?.toString();
    } catch (_) {}

    if (patientId != null && patientId.isNotEmpty) {
      await PatientOnboardingService.instance.initializeForPatient(
        patientId: patientId,
        patientName: name,
        language: language,
      );
    }

    return result;
  }
}
