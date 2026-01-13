// import 'package:equatable/equatable.dart';

// class Reminder extends Equatable {
//   final String id;
//   final String userId;
//   final String? taskId;
//   final String? sessionId;
//   final String title; // Task title or Session title
//   final String? description;
//   final DateTime reminderTime; // When to show notification
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final bool isActive;
//   final String reminderType; // 'task' or 'session'
//   final int minutesBefore; // How many minutes before the event

//   const Reminder({
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

//   bool get isUpcoming => isActive && reminderTime.isAfter(DateTime.now());

//   bool get isPast => !isActive || reminderTime.isBefore(DateTime.now());

//   Reminder copyWith({
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
//     return Reminder(
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

//   @override
//   List<Object?> get props => [
//     id,
//     userId,
//     taskId,
//     sessionId,
//     title,
//     description,
//     reminderTime,
//     createdAt,
//     updatedAt,
//     isActive,
//     reminderType,
//     minutesBefore,
//   ];
// }
import 'package:equatable/equatable.dart';

enum ReminderStatus { upcoming, done }

class Reminder extends Equatable {
  final String id;
  final String userId;

  // Link to feature
  final String? taskId;
  final String? sessionId;

  final String title;
  final String? description;

  /// When notification fires
  final DateTime reminderTime;

  /// Toggle from UI
  final bool isActive;

  /// Lifecycle
  final ReminderStatus status;

  /// task | session
  final String reminderType;

  /// 15 min / 30 min etc
  final int minutesBefore;

  const Reminder({
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

  bool get isExpired => reminderTime.isBefore(DateTime.now());

  Reminder copyWith({bool? isActive, ReminderStatus? status}) {
    return Reminder(
      id: id,
      userId: userId,
      taskId: taskId,
      sessionId: sessionId,
      title: title,
      description: description,
      reminderTime: reminderTime,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      reminderType: reminderType,
      minutesBefore: minutesBefore,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    taskId,
    sessionId,
    title,
    reminderTime,
    isActive,
    status,
    reminderType,
    minutesBefore,
  ];
}
