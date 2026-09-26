
class DataScope {
  final String? userId;
  final String? patientId;
  final String? caregiverId;

  const DataScope({
    this.userId,
    this.patientId,
    this.caregiverId,
  });

  bool get hasPatient =>
      patientId != null &&
      patientId!.isNotEmpty;

  bool get hasCaregiver =>
      caregiverId != null &&
      caregiverId!.isNotEmpty;
}
