import 'package:hive/hive.dart';
import 'package:smart_study_plan/core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/task_model.dart';

abstract class TaskLocalDatasource {
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<void> cacheTask(TaskModel task);
  Future<List<TaskModel>> getCachedTasksBySubject(String subjectId);
  Future<List<TaskModel>> getCachedTasksByUser(String userId);
  Future<List<TaskModel>> getAllCachedTasks();
  Future<void> clearCache();
}

class TaskLocalDatasourceImpl implements TaskLocalDatasource {
  final Box<TaskModel> tasksBox;

  TaskLocalDatasourceImpl({required this.tasksBox});

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    try {
      await tasksBox.clear();
      for (var task in tasks) {
        await tasksBox.put(task.id, task);
      }
      AppLogger.d('Cached ${tasks.length} tasks');
    } catch (e) {
      throw CacheException('Failed to cache tasks: $e');
    }
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    try {
      await tasksBox.put(task.id, task);
      AppLogger.d('Cached task: ${task.id}');
    } catch (e) {
      throw CacheException('Failed to cache task: $e');
    }
  }

  @override
  Future<List<TaskModel>> getCachedTasksBySubject(String subjectId) async {
    try {
      final tasks = tasksBox.values
          .where((t) => t.subjectId == subjectId)
          .toList();
      return tasks;
    } catch (e) {
      throw CacheException('Failed to get cached tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getCachedTasksByUser(String userId) async {
    try {
      final tasks = tasksBox.values.where((t) => t.userId == userId).toList();
      return tasks;
    } catch (e) {
      throw CacheException('Failed to get cached tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getAllCachedTasks() async {
    try {
      final tasks = tasksBox.values.toList();
      return tasks;
    } catch (e) {
      throw CacheException('Failed to get all cached tasks: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await tasksBox.clear();
      AppLogger.d('Cleared tasks cache');
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}
