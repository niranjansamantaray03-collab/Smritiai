import '../../features/memory/models/memory_story.dart';

class MemoryRepository {
  final List<MemoryStory> _stories = [];

  List<MemoryStory> get stories => List.unmodifiable(_stories);

  Future<void> add(MemoryStory story) async {
    _stories.add(story);
  }

  Future<void> remove(String id) async {
    _stories.removeWhere((story) => story.id == id);
  }

  List<MemoryStory> forPatient(String patientId) {
    return _stories
        .where((story) => story.patientId == patientId)
        .toList();
  }
}
