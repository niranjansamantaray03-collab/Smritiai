
class PatientConnection {
  final String id;
  final String caregiverId;
  final String patientId;
  final String status;
  final DateTime createdAt;

  const PatientConnection({
    required this.id,
    required this.caregiverId,
    required this.patientId,
    required this.status,
    required this.createdAt,
  });

  bool get isConnected =>
      status == 'connected';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caregiver_id': caregiverId,
      'patient_id': patientId,
      'status': status,
      'created_at':
          createdAt.toIso8601String(),
    };
  }

  factory PatientConnection.fromMap(
    Map<String, dynamic> map,
  ) {
    return PatientConnection(
      id: map['id'] as String? ?? '',
      caregiverId:
          map['caregiver_id'] as String? ??
              '',
      patientId:
          map['patient_id'] as String? ??
              '',
      status:
          map['status'] as String? ??
              'pending',
      createdAt:
          DateTime.tryParse(
                map['created_at']
                        as String? ??
                    '',
              ) ??
              DateTime.now(),
    );
  }
}
