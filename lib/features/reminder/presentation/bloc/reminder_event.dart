import '../../domain/entities/reminder.dart';

abstract class ReminderEvent {}

/// Load reminders for a user
class GetRemindersEvent extends ReminderEvent {
  final String userId;
  GetRemindersEvent(this.userId);
}

/// Create reminder
class CreateReminderEvent extends ReminderEvent {
  final Reminder reminder;
  CreateReminderEvent(this.reminder);
}

/// Toggle reminder ON / OFF
class ToggleReminderActiveEvent extends ReminderEvent {
  final String reminderId;
  final bool isActive;
  ToggleReminderActiveEvent(this.reminderId, this.isActive);
}

/// When reminder notification is triggered
class MarkReminderTriggeredEvent extends ReminderEvent {
  final String reminderId;
  MarkReminderTriggeredEvent(this.reminderId);
}

/// Mark reminder done when task is completed
class MarkReminderDoneByTaskEvent extends ReminderEvent {
  final String taskId;
  MarkReminderDoneByTaskEvent(this.taskId);
}

/// Delete reminder
class DeleteReminderEvent extends ReminderEvent {
  final String reminderId;
  DeleteReminderEvent(this.reminderId);
}
