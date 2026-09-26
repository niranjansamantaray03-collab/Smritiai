import '../../features/games/models/game_result.dart';

class GameRepository {
  final List<GameResult> _results = [];

  List<GameResult> get results => List.unmodifiable(_results);

  Future<void> save(GameResult result) async {
    _results.add(result);
  }

  List<GameResult> forPatient(String patientId) {
    return _results
        .where((result) => result.patientId == patientId)
        .toList();
  }
}
