import 'package:equatable/equatable.dart';

class StudySession extends Equatable {
  final String id;
  final String userId;
  final String? taskId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String? subjectId;
  final String? location;
  final bool isRecurring;
  final String? recurrencePattern; // daily|weekly|monthly
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudySession({
    required this.id,
    required this.userId,
    this.taskId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.subjectId,
    this.location,
    required this.isRecurring,
    this.recurrencePattern,
    required this.createdAt,
    required this.updatedAt,
  });

  Duration get duration => endTime.difference(startTime);

  bool get isUpcoming => startTime.isAfter(DateTime.now());

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isPast => endTime.isBefore(DateTime.now());

  StudySession copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? subjectId,
    String? location,
    bool? isRecurring,
    String? recurrencePattern,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subjectId: subjectId ?? this.subjectId,
      location: location ?? this.location,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    taskId,
    title,
    description,
    startTime,
    endTime,
    subjectId,
    location,
    isRecurring,
    recurrencePattern,
    createdAt,
    updatedAt,
  ];
}
