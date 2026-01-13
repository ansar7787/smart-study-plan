import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/reminder_repository.dart';

class GetTaskRemindersUseCase implements UseCase<List<Reminder>, String> {
  final ReminderRepository repository;

  GetTaskRemindersUseCase(this.repository);

  @override
  RemindersResult call(String taskId) {
    return repository.getRemindersByTaskId(taskId);
  }
}
