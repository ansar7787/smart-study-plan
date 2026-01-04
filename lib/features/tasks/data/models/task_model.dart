import 'package:hive/hive.dart';
import 'package:smart_study_plan/features/tasks/domain/entities/task.dart';

part 'task_model.g.dart'; // Run: flutter pub run build_runner build

@HiveType(typeId: 4) // unique typeId
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String subjectId;

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final int priority;

  @HiveField(7)
  final String userId;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.subjectId,
    required this.dueDate,
    required this.isCompleted,
    required this.priority,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Entity
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      subjectId: subjectId,
      dueDate: dueDate,
      isCompleted: isCompleted,
      priority: priority,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Convert from Entity
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      subjectId: task.subjectId,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      priority: task.priority,
      userId: task.userId,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  // Convert from JSON (Firestore)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      subjectId: json['subjectId'] ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'] ?? 2,
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
