import '../../features/rudas/models/rudas_assessment.dart';

class RudasRepository {
  final List<RudasAssessment> _assessments = [];

  List<RudasAssessment> get assessments =>
      List.unmodifiable(_assessments);

  Future<void> save(RudasAssessment assessment) async {
    _assessments.add(assessment);
  }

  List<RudasAssessment> forPatient(String patientId) {
    return _assessments
        .where((assessment) => assessment.patientId == patientId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  RudasAssessment? latestForPatient(String patientId) {
    final items = forPatient(patientId);

    if (items.isEmpty) return null;

    return items.last;
  }
}
