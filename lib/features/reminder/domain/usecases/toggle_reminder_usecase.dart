// import 'package:smart_study_plan/core/usecase/usecase.dart';
// import '../../../../core/utils/typedef.dart';
// import '../repositories/reminder_repository.dart';

// class ToggleReminderUseCase implements UseCase<void, ToggleReminderParams> {
//   final ReminderRepository repository;

//   ToggleReminderUseCase(this.repository);

//   @override
//   ResultVoid call(ToggleReminderParams params) {
//     return repository.toggleReminderActive(params.reminderId, params.isActive);
//   }
// }

// class ToggleReminderParams {
//   final String reminderId;
//   final bool isActive;

//   const ToggleReminderParams({
//     required this.reminderId,
//     required this.isActive,
//   });
// }
import 'package:smart_study_plan/core/usecase/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/reminder_repository.dart';

class ToggleReminderUseCase implements UseCase<void, ToggleReminderParams> {
  final ReminderRepository repository;

  ToggleReminderUseCase(this.repository);

  @override
  ResultVoid call(ToggleReminderParams params) {
    return repository.toggleReminderActive(params.reminderId, params.isActive);
  }
}

class ToggleReminderParams {
  final String reminderId;
  final bool isActive;

  const ToggleReminderParams({
    required this.reminderId,
    required this.isActive,
  });
}
