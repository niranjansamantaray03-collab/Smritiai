
import '../remote/cloud_repository.dart';
import '../../features/tasks/models/caregiver_task.dart';
import '../../features/notifications/reminder.dart';

class TaskReminderSync {
  final CloudRepository cloud;

  TaskReminderSync(this.cloud);

  Future<void> pushTask(CaregiverTask task) async {
    await cloud.saveTask(task.toMap());
  }

  Future<void> pushReminder(SmritiReminder reminder) async {
    await cloud.saveReminder(reminder.toMap());
  }

  Future<List<Map<String, dynamic>>> pullTasks(String patientId) {
    return cloud.getTasks(patientId);
  }

  Future<List<Map<String, dynamic>>> pullReminders(String patientId) {
    return cloud.getReminders(patientId);
  }
}
