// import 'package:hive/hive.dart';
// import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart.dart';

// part 'reminder_model.g.dart';

// @HiveType(typeId: 7)
// class ReminderModel extends HiveObject {
//   @HiveField(0)
//   final String id;

//   @HiveField(1)
//   final String userId;

//   @HiveField(2)
//   final String? taskId;

//   @HiveField(3)
//   final String? sessionId;

//   @HiveField(4)
//   final String title;

//   @HiveField(5)
//   final String? description;

//   @HiveField(6)
//   final DateTime reminderTime;

//   @HiveField(7)
//   final DateTime createdAt;

//   @HiveField(8)
//   final DateTime updatedAt;

//   @HiveField(9)
//   final bool isActive;

//   @HiveField(10)
//   final String reminderType; // 'task' or 'session'

//   @HiveField(11)
//   final int minutesBefore;

//   ReminderModel({
//     required this.id,
//     required this.userId,
//     this.taskId,
//     this.sessionId,
//     required this.title,
//     this.description,
//     required this.reminderTime,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.isActive,
//     required this.reminderType,
//     required this.minutesBefore,
//   });

//   Reminder toEntity() {
//     return Reminder(
//       id: id,
//       userId: userId,
//       taskId: taskId,
//       sessionId: sessionId,
//       title: title,
//       description: description,
//       reminderTime: reminderTime,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//       isActive: isActive,
//       reminderType: reminderType,
//       minutesBefore: minutesBefore,
//     );
//   }

//   factory ReminderModel.fromEntity(Reminder reminder) {
//     return ReminderModel(
//       id: reminder.id,
//       userId: reminder.userId,
//       taskId: reminder.taskId,
//       sessionId: reminder.sessionId,
//       title: reminder.title,
//       description: reminder.description,
//       reminderTime: reminder.reminderTime,
//       createdAt: reminder.createdAt,
//       updatedAt: reminder.updatedAt,
//       isActive: reminder.isActive,
//       reminderType: reminder.reminderType,
//       minutesBefore: reminder.minutesBefore,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'taskId': taskId,
//       'sessionId': sessionId,
//       'title': title,
//       'description': description,
//       'reminderTime': reminderTime.toIso8601String(),
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//       'isActive': isActive,
//       'reminderType': reminderType,
//       'minutesBefore': minutesBefore,
//     };
//   }

//   ReminderModel copyWith({
//     String? id,
//     String? userId,
//     String? taskId,
//     String? sessionId,
//     String? title,
//     String? description,
//     DateTime? reminderTime,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     bool? isActive,
//     String? reminderType,
//     int? minutesBefore,
//   }) {
//     return ReminderModel(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       taskId: taskId ?? this.taskId,
//       sessionId: sessionId ?? this.sessionId,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       reminderTime: reminderTime ?? this.reminderTime,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       isActive: isActive ?? this.isActive,
//       reminderType: reminderType ?? this.reminderType,
//       minutesBefore: minutesBefore ?? this.minutesBefore,
//     );
//   }

//   factory ReminderModel.fromJson(Map<String, dynamic> json) {
//     return ReminderModel(
//       id: json['id'] ?? '',
//       userId: json['userId'] ?? '',
//       taskId: json['taskId'],
//       sessionId: json['sessionId'],
//       title: json['title'] ?? '',
//       description: json['description'],
//       reminderTime: json['reminderTime'] is DateTime
//           ? json['reminderTime']
//           : DateTime.parse(json['reminderTime']),
//       createdAt: json['createdAt'] is DateTime
//           ? json['createdAt']
//           : DateTime.parse(json['createdAt']),
//       updatedAt: json['updatedAt'] is DateTime
//           ? json['updatedAt']
//           : DateTime.parse(json['updatedAt']),
//       isActive: json['isActive'] ?? true,
//       reminderType: json['reminderType'] ?? 'task',
//       minutesBefore: json['minutesBefore'] ?? 15,
//     );
//   }
// }
import 'package:hive/hive.dart';
import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 7)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String? taskId;

  @HiveField(3)
  final String? sessionId;

  @HiveField(4)
  final String title;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final DateTime reminderTime;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final String status; // upcoming | done

  @HiveField(9)
  final String reminderType;

  @HiveField(10)
  final int minutesBefore;

  ReminderModel({
    required this.id,
    required this.userId,
    this.taskId,
    this.sessionId,
    required this.title,
    this.description,
    required this.reminderTime,
    required this.isActive,
    required this.status,
    required this.reminderType,
    required this.minutesBefore,
  });

  Reminder toEntity() => Reminder(
    id: id,
    userId: userId,
    taskId: taskId,
    sessionId: sessionId,
    title: title,
    description: description,
    reminderTime: reminderTime,
    isActive: isActive,
    status: ReminderStatus.values.byName(status),
    reminderType: reminderType,
    minutesBefore: minutesBefore,
  );

  factory ReminderModel.fromEntity(Reminder r) {
    return ReminderModel(
      id: r.id,
      userId: r.userId,
      taskId: r.taskId,
      sessionId: r.sessionId,
      title: r.title,
      description: r.description,
      reminderTime: r.reminderTime,
      isActive: r.isActive,
      status: r.status.name,
      reminderType: r.reminderType,
      minutesBefore: r.minutesBefore,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'taskId': taskId,
    'sessionId': sessionId,
    'title': title,
    'description': description,
    'reminderTime': reminderTime.toIso8601String(),
    'isActive': isActive,
    'status': status,
    'reminderType': reminderType,
    'minutesBefore': minutesBefore,
  };

  ReminderModel copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? sessionId,
    String? title,
    String? description,
    DateTime? reminderTime,
    bool? isActive,
    String? status,
    String? reminderType,
    int? minutesBefore,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      reminderType: reminderType ?? this.reminderType,
      minutesBefore: minutesBefore ?? this.minutesBefore,
    );
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      userId: json['userId'],
      taskId: json['taskId'],
      sessionId: json['sessionId'],
      title: json['title'],
      description: json['description'],
      reminderTime: DateTime.parse(json['reminderTime']),
      isActive: json['isActive'],
      status: json['status'],
      reminderType: json['reminderType'],
      minutesBefore: json['minutesBefore'],
    );
  }
}
