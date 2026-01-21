import 'package:hive/hive.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<void> cacheTask(TaskModel taskModel);
  Future<void> deleteCachedTask(String taskId);
  Future<List<TaskModel>> getCachedTasksBySubject(String subjectId);
  Future<List<TaskModel>> getAllCachedTasks(); // ✅ NEW
  Future<void> clearTaskCache();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const String tasksBoxName = 'tasks';

  @override
  Future<void> cacheTask(TaskModel taskModel) async {
    final box = await Hive.openBox<TaskModel>(tasksBoxName);
    await box.put(taskModel.id, taskModel);
  }

  @override
  Future<void> deleteCachedTask(String taskId) async {
    final box = await Hive.openBox<TaskModel>(tasksBoxName);
    await box.delete(taskId);
  }

  @override
  Future<List<TaskModel>> getCachedTasksBySubject(String subjectId) async {
    final box = await Hive.openBox<TaskModel>(tasksBoxName);
    return box.values.where((task) => task.subjectId == subjectId).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Future<List<TaskModel>> getAllCachedTasks() async {
    final box = await Hive.openBox<TaskModel>(tasksBoxName);
    return box.values.toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Future<void> clearTaskCache() async {
    final box = await Hive.openBox<TaskModel>(tasksBoxName);
    await box.clear();
  }
}
