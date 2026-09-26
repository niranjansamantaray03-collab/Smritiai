
import '../features/notifications/notification_request.dart';

enum NotificationPermissionStatus {
  unknown,
  granted,
  denied,
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  NotificationPermissionStatus
      _permission =
      NotificationPermissionStatus.unknown;

  final Map<int, NotificationRequest>
      _scheduled = {};

  NotificationPermissionStatus get permission =>
      _permission;

  List<NotificationRequest>
      get scheduled =>
          List.unmodifiable(
            _scheduled.values,
          );

  Future<void> initialize() async {
    // Android notification plugin initialization
    // is intentionally kept behind this service.
  }

  Future<NotificationPermissionStatus>
      requestPermission() async {
    // Final Android implementation will call
    // POST_NOTIFICATIONS permission here.
    _permission =
        NotificationPermissionStatus.granted;

    return _permission;
  }

  Future<void> schedule(
    NotificationRequest request,
  ) async {
    await initialize();

    if (_permission !=
        NotificationPermissionStatus.granted) {
      await requestPermission();
    }

    _scheduled[request.id] = request;
  }

  Future<void> cancel(int id) async {
    _scheduled.remove(id);
  }

  Future<void> cancelAll() async {
    _scheduled.clear();
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    _scheduled[id] = NotificationRequest(
      id: id,
      title: title,
      body: body,
      scheduledAt: DateTime.now(),
      payload: payload,
    );
  }

  int stableNotificationId(
    String reminderId,
  ) {
    var hash = 0;

    for (final code
        in reminderId.codeUnits) {
      hash =
          ((hash << 5) - hash) + code;
      hash &= 0x7fffffff;
    }

    return hash == 0 ? 1 : hash;
  }
}
