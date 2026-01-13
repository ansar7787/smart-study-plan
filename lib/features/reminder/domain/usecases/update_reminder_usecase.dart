// import 'package:smart_study_plan/core/usecase/usecase.dart';
// import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart.dart';
// import '../../../../core/utils/typedef.dart';
// import '../repositories/reminder_repository.dart';

// class UpdateReminderUseCase implements UseCase<Reminder, UpdateReminderParams> {
//   final ReminderRepository repository;

//   UpdateReminderUseCase(this.repository);

//   @override
//   ReminderResult call(UpdateReminderParams params) {
//     return repository.updateReminder(params.reminder);
//   }
// }

// class UpdateReminderParams {
//   final Reminder reminder;

//   const UpdateReminderParams({required this.reminder});
// }

import 'package:smart_study_plan/core/usecase/usecase.dart';
import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/reminder_repository.dart';

class UpdateReminderUseCase implements UseCase<Reminder, UpdateReminderParams> {
  final ReminderRepository repository;

  UpdateReminderUseCase(this.repository);

  @override
  ReminderResult call(UpdateReminderParams params) {
    return repository.updateReminder(params.reminder);
  }
}

class UpdateReminderParams {
  final Reminder reminder;
  const UpdateReminderParams({required this.reminder});
}
