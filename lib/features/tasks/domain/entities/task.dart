import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String subjectId; // foreign key to Subject
  final DateTime dueDate;
  final bool isCompleted;
  final int priority; // 1=low, 2=medium, 3=high
  final String userId; // student who created this task
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
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

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    subjectId,
    dueDate,
    isCompleted,
    priority,
    userId,
    createdAt,
    updatedAt,
  ];

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? subjectId,
    DateTime? dueDate,
    bool? isCompleted,
    int? priority,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
