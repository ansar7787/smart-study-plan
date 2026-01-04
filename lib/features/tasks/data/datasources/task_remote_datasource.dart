import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_study_plan/core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDatasource {
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> getTask(String id);
  Future<List<TaskModel>> getTasksBySubject(String subjectId);
  Future<List<TaskModel>> getTasksByUser(String userId);
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDatasourceImpl implements TaskRemoteDatasource {
  final FirebaseFirestore firestore;

  TaskRemoteDatasourceImpl({required this.firestore});

  final String _collection = 'tasks';

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final docRef = firestore.collection(_collection).doc(task.id);
      await docRef.set(task.toJson());
      AppLogger.d('Task created: ${task.id}');
      return task;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }

  @override
  Future<TaskModel> getTask(String id) async {
    try {
      final doc = await firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw ServerException('Task not found');
      }
      return TaskModel.fromJson(doc.data() ?? {});
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }

  @override
  Future<List<TaskModel>> getTasksBySubject(String subjectId) async {
    try {
      final querySnapshot = await firestore
          .collection(_collection)
          .where('subjectId', isEqualTo: subjectId)
          .orderBy('dueDate', descending: false)
          .get();
      return querySnapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByUser(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate', descending: false)
          .get();
      return querySnapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final querySnapshot = await firestore
          .collection(_collection)
          .orderBy('dueDate')
          .get();
      return querySnapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      await firestore
          .collection(_collection)
          .doc(task.id)
          .update(task.toJson());
      AppLogger.d('Task updated: ${task.id}');
      return task;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await firestore.collection(_collection).doc(id).delete();
      AppLogger.d('Task deleted: $id');
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    }
  }
}
