import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_study_plan/features/tasks/domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final List<String> tags;

  @HiveField(6)
  final int priority;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final DateTime dueDate;

  @HiveField(9)
  final DateTime? estimatedTime;

  @HiveField(10)
  final bool isCompleted;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.subjectId,
    required this.userId,
    required this.title,
    required this.description,
    required this.tags,
    required this.priority,
    required this.status,
    required this.dueDate,
    this.estimatedTime,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  // -------------------- ENTITY --------------------

  Task toEntity() {
    return Task(
      id: id,
      subjectId: subjectId,
      userId: userId,
      title: title,
      description: description,
      tags: tags,
      priority: priority,
      status: status,
      dueDate: dueDate,
      estimatedTime: estimatedTime,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      subjectId: task.subjectId,
      userId: task.userId,
      title: task.title,
      description: task.description,
      tags: task.tags,
      priority: task.priority,
      status: task.status,
      dueDate: task.dueDate,
      estimatedTime: task.estimatedTime,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  // -------------------- FIRESTORE --------------------

  /// 🔥 SAFE DATE PARSER (THIS FIXES YOUR BUG)
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.parse(value);
    }

    throw Exception('Invalid date type: $value');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'userId': userId,
      'title': title,
      'description': description,
      'tags': tags,
      'priority': priority,
      'status': status,
      'dueDate': Timestamp.fromDate(dueDate), // ✅ FIX
      'estimatedTime': estimatedTime != null
          ? Timestamp.fromDate(estimatedTime!)
          : null,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt), // ✅ FIX
      'updatedAt': Timestamp.fromDate(updatedAt), // ✅ FIX
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      subjectId: json['subjectId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      priority: json['priority'] ?? 2,
      status: json['status'] ?? 'todo',
      dueDate: _parseDate(json['dueDate']),
      estimatedTime: json['estimatedTime'] != null
          ? _parseDate(json['estimatedTime'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}
