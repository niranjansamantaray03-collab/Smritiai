
import 'dart:developer' as developer;

class SecurityEventLogger {
  SecurityEventLogger._();

  static final SecurityEventLogger instance =
      SecurityEventLogger._();

  void info(
    String event, {
    Map<String, Object?> details = const {},
  }) {
    developer.log(
      '$event | $details',
      name: 'SmritiAI.Security',
    );
  }

  void blocked(
    String event, {
    Map<String, Object?> details = const {},
  }) {
    developer.log(
      'BLOCKED: $event | $details',
      name: 'SmritiAI.Security',
      level: 900,
    );
  }

  void error(
    String event,
    Object error, {
    StackTrace? stackTrace,
  }) {
    developer.log(
      event,
      name: 'SmritiAI.Security',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
