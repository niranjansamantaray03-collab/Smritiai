
class DeviceResult<T> {
  final bool success;
  final T? value;
  final String? message;

  const DeviceResult._({
    required this.success,
    this.value,
    this.message,
  });

  factory DeviceResult.success([T? value]) {
    return DeviceResult._(
      success: true,
      value: value,
    );
  }

  factory DeviceResult.failure(String message) {
    return DeviceResult._(
      success: false,
      message: message,
    );
  }
}
