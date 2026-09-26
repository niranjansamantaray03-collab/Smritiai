import '../../features/tasks/models/caregiver_task.dart';

class TaskRepository {
  final List<CaregiverTask> _tasks = [];

  List<CaregiverTask> get tasks => List.unmodifiable(_tasks);

  Future<void> save(CaregiverTask task) async {
    _tasks.removeWhere((item) => item.id == task.id);
    _tasks.add(task);
  }

  Future<void> markCompleted(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);

    if (index == -1) return;

    final task = _tasks[index];

    _tasks[index] = task.copyWith(
      completed: true,
      completedAt: DateTime.now(),
    );
  }

  List<CaregiverTask> forPatient(String patientId) {
    return _tasks
        .where((task) => task.patientId == patientId)
        .toList();
  }
}
