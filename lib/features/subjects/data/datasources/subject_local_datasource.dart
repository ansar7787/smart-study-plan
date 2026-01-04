import 'package:hive/hive.dart';
import 'package:smart_study_plan/core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/subject_model.dart';

abstract class SubjectLocalDatasource {
  Future<void> cacheSubjects(List<SubjectModel> subjects);
  Future<void> cacheSubject(SubjectModel subject);
  Future<List<SubjectModel>> getCachedSubjectsByUser(String userId);
  Future<List<SubjectModel>> getAllCachedSubjects();
  Future<void> clearCache();
}

class SubjectLocalDatasourceImpl implements SubjectLocalDatasource {
  final Box<SubjectModel> subjectsBox;

  SubjectLocalDatasourceImpl({required this.subjectsBox});

  @override
  Future<void> cacheSubjects(List<SubjectModel> subjects) async {
    try {
      await subjectsBox.clear();
      for (var subject in subjects) {
        await subjectsBox.put(subject.id, subject);
      }
      AppLogger.d('Cached ${subjects.length} subjects');
    } catch (e) {
      throw CacheException('Failed to cache subjects: $e');
    }
  }

  @override
  Future<void> cacheSubject(SubjectModel subject) async {
    try {
      await subjectsBox.put(subject.id, subject);
      AppLogger.d('Cached subject: ${subject.id}');
    } catch (e) {
      throw CacheException('Failed to cache subject: $e');
    }
  }

  @override
  Future<List<SubjectModel>> getCachedSubjectsByUser(String userId) async {
    try {
      final subjects = subjectsBox.values
          .where((s) => s.userId == userId)
          .toList();
      return subjects;
    } catch (e) {
      throw CacheException('Failed to get cached subjects: $e');
    }
  }

  @override
  Future<List<SubjectModel>> getAllCachedSubjects() async {
    try {
      final subjects = subjectsBox.values.toList();
      return subjects;
    } catch (e) {
      throw CacheException('Failed to get all cached subjects: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await subjectsBox.clear();
      AppLogger.d('Cleared subjects cache');
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}
