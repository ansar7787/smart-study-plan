import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:smart_study_plan/features/planner/domain/entities/study_session.dart';

part 'study_session_model.g.dart';

@HiveType(typeId: 2)
class StudySessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String? taskId;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final DateTime startTime;

  @HiveField(6)
  final DateTime endTime;

  @HiveField(7)
  final String? subjectId;

  @HiveField(8)
  final String? location;

  @HiveField(9)
  final bool isRecurring;

  @HiveField(10)
  final String? recurrencePattern;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  StudySessionModel({
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

  StudySession toEntity() {
    return StudySession(
      id: id,
      userId: userId,
      taskId: taskId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      subjectId: subjectId,
      location: location,
      isRecurring: isRecurring,
      recurrencePattern: recurrencePattern,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory StudySessionModel.fromEntity(StudySession session) {
    return StudySessionModel(
      id: session.id,
      userId: session.userId,
      taskId: session.taskId,
      title: session.title,
      description: session.description,
      startTime: session.startTime,
      endTime: session.endTime,
      subjectId: session.subjectId,
      location: session.location,
      isRecurring: session.isRecurring,
      recurrencePattern: session.recurrencePattern,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'taskId': taskId,
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'subjectId': subjectId,
      'location': location,
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      taskId: json['taskId']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: _parseDate(json['startTime']),
      endTime: _parseDate(json['endTime']),
      subjectId: json['subjectId']?.toString(),
      location: json['location']?.toString(),
      isRecurring: json['isRecurring'] ?? false,
      recurrencePattern: json['recurrencePattern']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}

DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();

  if (value is DateTime) return value;

  if (value is Timestamp) return value.toDate();

  if (value is String) return DateTime.parse(value);

  if (value is int) {
    // millisecondsSinceEpoch
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  throw Exception('Unsupported date type: ${value.runtimeType}');
}
