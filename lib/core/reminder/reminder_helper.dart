import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import 'package:uuid/uuid.dart';

class ReminderHelper {
  static Reminder fromTask({
    required String userId,
    required String taskId,
    required String title,
    required DateTime dueDate,
    int minutesBefore = 30,
  }) {
    return Reminder(
      id: const Uuid().v4(),
      userId: userId,
      taskId: taskId,
      sessionId: null,
      title: title,
      reminderTime: dueDate.subtract(Duration(minutes: minutesBefore)),
      isActive: true,
      status: ReminderStatus.upcoming,
      reminderType: 'task',
      minutesBefore: minutesBefore,
    );
  }

  static Reminder fromSession({
    required String userId,
    required String sessionId,
    required String title,
    required DateTime startTime,
    int minutesBefore = 15,
  }) {
    return Reminder(
      id: const Uuid().v4(),
      userId: userId,
      taskId: null,
      sessionId: sessionId,
      title: title,
      reminderTime: startTime.subtract(Duration(minutes: minutesBefore)),
      isActive: true,
      status: ReminderStatus.upcoming,
      reminderType: 'session',
      minutesBefore: minutesBefore,
    );
  }
}
