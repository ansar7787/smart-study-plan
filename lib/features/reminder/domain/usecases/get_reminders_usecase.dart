import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/reminder_repository.dart';

class GetRemindersUseCase implements UseCase<List<Reminder>, String> {
  final ReminderRepository repository;

  GetRemindersUseCase(this.repository);

  @override
  RemindersResult call(String userId) {
    return repository.getRemindersByUserId(userId);
  }
}
