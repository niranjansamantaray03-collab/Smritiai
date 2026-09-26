
enum BackendEnvironment {
  offline,
  production,
}

class BackendEnvironmentInfo {
  const BackendEnvironmentInfo({
    required this.environment,
    required this.isConfigured,
  });

  final BackendEnvironment environment;
  final bool isConfigured;

  bool get isProduction =>
      environment == BackendEnvironment.production;

  bool get isOffline =>
      environment == BackendEnvironment.offline;
}
