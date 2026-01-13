import 'package:smart_study_plan/core/usecase/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/reminder_repository.dart';

class MarkReminderTriggeredUseCase implements UseCase<void, String> {
  final ReminderRepository repository;

  MarkReminderTriggeredUseCase(this.repository);

  @override
  ResultVoid call(String reminderId) {
    return repository.toggleReminderActive(reminderId, false);
  }
}
