
import '../../data/remote/supabase_data_service.dart';
import '../../services/supabase_auth_service.dart';
import 'auth_session.dart';
import 'auth_user.dart';

class AuthManager {
  AuthManager._();

  static final AuthManager instance = AuthManager._();

  AuthSession? _session;

  AuthSession? get session => _session;

  AuthUser? get currentUser => _session?.user;

  bool get isLoggedIn => _session != null;

  bool get cloudAvailable =>
      SupabaseAuthService.instance.available;

  Future<AuthSession?> restoreSession() async {
    final cloud = SupabaseAuthService.instance;

    if (!cloud.available) {
      return _session;
    }

    final userId = cloud.currentUserId;

    if (userId == null) {
      _session = null;
      return null;
    }

    final profile =
        await SupabaseDataService.instance.getProfile(userId);

    if (profile == null) {
      _session = null;
      return null;
    }

    final user = AuthUser(
      id: userId,
      name: (profile['name'] ?? 'SmritiAI User').toString(),
      email: cloud.currentEmail ?? '',
      role: (profile['role'] ?? 'patient').toString(),
      language: (profile['language'] ?? 'en').toString(),
    );

    _session = AuthSession(
      user: user,
      token: '',
    );

    return _session;
  }

  Future<AuthSession?> login(
    String email,
    String password,
  ) async {
    final cloud = SupabaseAuthService.instance;

    // --------------------------------------------------------
    // PRODUCTION CLOUD LOGIN
    // --------------------------------------------------------

    if (cloud.available) {
      try {
        final success = await cloud.signIn(
          email: email,
          password: password,
        );

        if (success) {
          final userId = cloud.currentUserId;

          if (userId == null) {
            return null;
          }

          final profile =
              await SupabaseDataService.instance.getProfile(userId);

          if (profile == null) {
            return null;
          }

          final user = AuthUser(
            id: userId,
            name: (profile['name'] ?? 'SmritiAI User').toString(),
            email: cloud.currentEmail ?? email,
            role: (profile['role'] ?? 'patient').toString(),
            language: (profile['language'] ?? 'en').toString(),
          );

          _session = AuthSession(
            user: user,
            token: '',
          );

          return _session;
        }
      } catch (_) {
        // Cloud login failed.
        // Fall through to demo credentials below.
      }
    }

    // --------------------------------------------------------
    // DEMO / OFFLINE FALLBACK
    // --------------------------------------------------------

    if (email.trim().toLowerCase() == 'patient@smriti.ai' &&
        password == '1234') {
      _session = AuthSession(
        user: AuthUser(
          id: 'p1',
          name: 'Aarav Sharma',
          email: email,
          role: 'patient',
          language: 'en',
        ),
        token: 'demo-patient',
      );

      return _session;
    }

    if (email.trim().toLowerCase() == 'caregiver@smriti.ai' &&
        password == '1234') {
      _session = AuthSession(
        user: AuthUser(
          id: 'c1',
          name: 'Meera Sharma',
          email: email,
          role: 'caregiver',
          language: 'en',
        ),
        token: 'demo-caregiver',
      );

      return _session;
    }

    return null;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String language = 'en',
  }) async {
    final cloud = SupabaseAuthService.instance;

    if (!cloud.available) {
      return false;
    }

    try {
      final success = await cloud.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        language: language,
      );

      if (!success) {
        return false;
      }

      await restoreSession();

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (SupabaseAuthService.instance.available) {
        await SupabaseAuthService.instance.signOut();
      }
    } catch (_) {}

    _session = null;
  }
}
