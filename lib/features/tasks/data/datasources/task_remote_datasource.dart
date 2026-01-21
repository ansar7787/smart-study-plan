import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<void> createTask(TaskModel taskModel);
  Future<void> updateTask(TaskModel taskModel);
  Future<void> deleteTask(String taskId);
  Future<List<TaskModel>> getTasksBySubject(String subjectId, String userId);
  Future<List<TaskModel>> getTasksByUser(String userId);
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel> getTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createTask(TaskModel taskModel) async {
    await firestore
        .collection('tasks')
        .doc(taskModel.id)
        .set(taskModel.toJson());
  }

  @override
  Future<void> updateTask(TaskModel taskModel) async {
    await firestore
        .collection('tasks')
        .doc(taskModel.id)
        .update(taskModel.toJson());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await firestore.collection('tasks').doc(taskId).delete();
  }

  @override
  Future<List<TaskModel>> getTasksBySubject(
    String subjectId,
    String userId,
  ) async {
    final querySnapshot = await firestore
        .collection('tasks')
        .where('subjectId', isEqualTo: subjectId)
        .where('userId', isEqualTo: userId)
        .orderBy('dueDate')
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<TaskModel>> getTasksByUser(String userId) async {
    final querySnapshot = await firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final querySnapshot = await firestore
        .collection('tasks')
        .orderBy('dueDate')
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<TaskModel> getTask(String id) async {
    final doc = await firestore.collection('tasks').doc(id).get();
    if (!doc.exists) {
      throw Exception('Task not found');
    }
    return TaskModel.fromJson(doc.data()!);
  }
}
