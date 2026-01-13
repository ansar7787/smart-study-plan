import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';

abstract class ReminderState {}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class RemindersLoaded extends ReminderState {
  final List<Reminder> reminders;
  RemindersLoaded(this.reminders);
}

class ReminderError extends ReminderState {
  final String message;
  ReminderError(this.message);
}
