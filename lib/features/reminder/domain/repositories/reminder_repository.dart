import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';

abstract class ReminderRepository {
  ReminderResult createReminder(Reminder reminder);

  ReminderResult updateReminder(Reminder reminder);

  ResultVoid deleteReminder(String reminderId);

  Future<Either<Failure, Reminder?>> getReminderById(String reminderId);

  RemindersResult getRemindersByUserId(String userId);

  RemindersResult getRemindersByTaskId(String taskId);

  RemindersResult getRemindersBySessionId(String sessionId);

  ResultVoid toggleReminderActive(String reminderId, bool isActive);
}
