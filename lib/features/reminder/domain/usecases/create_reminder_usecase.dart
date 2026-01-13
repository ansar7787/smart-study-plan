import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/reminder_repository.dart';

class CreateReminderUseCase implements UseCase<Reminder, CreateReminderParams> {
  final ReminderRepository repository;

  CreateReminderUseCase(this.repository);

  @override
  ReminderResult call(CreateReminderParams params) {
    return repository.createReminder(params.reminder);
  }
}

class CreateReminderParams {
  final Reminder reminder;
  const CreateReminderParams({required this.reminder});
}
