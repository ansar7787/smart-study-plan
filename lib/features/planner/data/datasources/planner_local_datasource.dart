import 'package:hive/hive.dart';
import 'package:smart_study_plan/features/planner/data/models/study_session_model.dart';

abstract class PlannerLocalDataSource {
  Future<void> cacheSession(StudySessionModel session);
  Future<void> deleteSession(String sessionId);
  Future<List<StudySessionModel>> getSessionsByDate(DateTime date);
  Future<List<StudySessionModel>> getSessionsByUser(String userId);
  Future<void> clearCache();
}

class PlannerLocalDataSourceImpl implements PlannerLocalDataSource {
  static const String sessionsBoxName = 'study_sessions';

  @override
  Future<void> cacheSession(StudySessionModel session) async {
    final box = await Hive.openBox<StudySessionModel>(sessionsBoxName);
    await box.put(session.id, session);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    final box = await Hive.openBox<StudySessionModel>(sessionsBoxName);
    await box.delete(sessionId);
  }

  @override
  Future<List<StudySessionModel>> getSessionsByDate(DateTime date) async {
    final box = await Hive.openBox<StudySessionModel>(sessionsBoxName);
    return box.values
        .where(
          (session) =>
              session.startTime.year == date.year &&
              session.startTime.month == date.month &&
              session.startTime.day == date.day,
        )
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<List<StudySessionModel>> getSessionsByUser(String userId) async {
    final box = await Hive.openBox<StudySessionModel>(sessionsBoxName);
    return box.values.where((session) => session.userId == userId).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<void> clearCache() async {
    final box = await Hive.openBox<StudySessionModel>(sessionsBoxName);
    await box.clear();
  }
}
