import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String subjectId;
  final String userId;
  final String title;
  final String description; // NEW
  final List<String> tags; // NEW
  final int priority; // 1=Low, 2=Medium, 3=High
  final String status; // NEW: todo|in_progress|completed|on_hold
  final DateTime? startDate; // NEW: Start Date & Time
  final DateTime dueDate;
  final DateTime? estimatedTime; // NEW
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.subjectId,
    required this.userId,
    required this.title,
    required this.description,
    required this.tags,
    required this.priority,
    required this.status,
    this.startDate,
    required this.dueDate,
    this.estimatedTime,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  // Copy with method for immutability
  Task copyWith({
    String? id,
    String? subjectId,
    String? userId,
    String? title,
    String? description,
    List<String>? tags,
    int? priority,
    String? status,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? estimatedTime,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    subjectId,
    userId,
    title,
    description,
    tags,
    priority,
    status,
    startDate,
    dueDate,
    estimatedTime,
    isCompleted,
    createdAt,
    updatedAt,
  ];
}
