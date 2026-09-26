
class AccessCheck {
  final bool allowed;
  final String reason;

  const AccessCheck._(
    this.allowed,
    this.reason,
  );

  const AccessCheck.allow()
      : this._(true, '');

  const AccessCheck.deny(String reason)
      : this._(false, reason);
}
