
class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String language;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.language = 'en',
  });

  bool get isPatient => role == 'patient';

  bool get isCaregiver => role == 'caregiver';

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? language,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      language: language ?? this.language,
    );
  }
}
