// import 'package:dartz/dartz.dart';
// import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart.dart';
// import '../../domain/repositories/reminder_repository.dart';
// import '../../../../core/error/failures.dart';
// import '../../../../core/utils/typedef.dart';
// import '../datasources/reminder_local_datasource.dart';
// import '../datasources/reminder_remote_datasource.dart';
// import '../models/reminder_model.dart';

// class ReminderRepositoryImpl implements ReminderRepository {
//   final ReminderLocalDataSource localDataSource;
//   final ReminderRemoteDataSource remoteDataSource;

//   ReminderRepositoryImpl({
//     required this.localDataSource,
//     required this.remoteDataSource,
//   });

//   @override
//   ReminderResult createReminder(Reminder reminder) async {
//     try {
//       final model = ReminderModel.fromEntity(reminder);

//       // Save locally first
//       final localResult = await localDataSource.cacheReminder(model);

//       if (localResult.isLeft()) {
//         return localResult.fold(
//           (failure) => Left(failure),
//           (_) => const Left(CacheFailure('Local save failed')),
//         );
//       }

//       // Try to save remotely (non-blocking)
//       final remoteResult = await remoteDataSource.createReminder(model);

//       return remoteResult.fold((failure) {
//         // Logged locally, will sync later
//         return Right(reminder);
//       }, (_) => Right(reminder));
//     } catch (e) {
//       return Left(CacheFailure('Error creating reminder: $e'));
//     }
//   }

//   @override
//   ReminderResult updateReminder(Reminder reminder) async {
//     try {
//       final model = ReminderModel.fromEntity(reminder);

//       final localResult = await localDataSource.cacheReminder(model);

//       if (localResult.isLeft()) {
//         return localResult.fold(
//           (failure) => Left(failure),
//           (_) => const Left(CacheFailure('Local update failed')),
//         );
//       }

//       await remoteDataSource.updateReminder(model);

//       return Right(reminder);
//     } catch (e) {
//       return Left(CacheFailure('Error updating reminder: $e'));
//     }
//   }

//   @override
//   ResultVoid deleteReminder(String reminderId) async {
//     try {
//       final localResult = await localDataSource.deleteReminder(reminderId);

//       if (localResult.isLeft()) {
//         return localResult;
//       }

//       await remoteDataSource.deleteReminder(reminderId);

//       return const Right(null);
//     } catch (e) {
//       return Left(CacheFailure('Error deleting reminder: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, Reminder?>> getReminderById(String reminderId) async {
//     try {
//       final result = await localDataSource.getReminderById(reminderId);

//       return result.fold((failure) async {
//         final remoteResult = await remoteDataSource.getReminderById(reminderId);
//         return remoteResult.fold(
//           (remoteFailure) => Left(remoteFailure),
//           (model) => Right(model?.toEntity()),
//         );
//       }, (model) => Right(model?.toEntity()));
//     } catch (e) {
//       return Left(CacheFailure('Error fetching reminder: $e'));
//     }
//   }

//   @override
//   RemindersResult getRemindersByUserId(String userId) async {
//     try {
//       final result = await localDataSource.getRemindersByUserId(userId);

//       return result.fold((failure) async {
//         final remoteResult = await remoteDataSource.getRemindersByUserId(
//           userId,
//         );
//         return remoteResult.fold(
//           (remoteFailure) => Left(remoteFailure),
//           (models) => Right(models.map((m) => m.toEntity()).toList()),
//         );
//       }, (models) => Right(models.map((m) => m.toEntity()).toList()));
//     } catch (e) {
//       return Left(CacheFailure('Error fetching reminders: $e'));
//     }
//   }

//   @override
//   RemindersResult getUpcomingReminders(String userId) async {
//     try {
//       final now = DateTime.now();
//       final result = await localDataSource.getUpcomingReminders(userId, now);

//       return result.fold((failure) async {
//         final remoteResult = await remoteDataSource.getUpcomingReminders(
//           userId,
//         );
//         return remoteResult.fold(
//           (remoteFailure) => Left(remoteFailure),
//           (models) => Right(models.map((m) => m.toEntity()).toList()),
//         );
//       }, (models) => Right(models.map((m) => m.toEntity()).toList()));
//     } catch (e) {
//       return Left(CacheFailure('Error fetching upcoming reminders: $e'));
//     }
//   }

//   @override
//   RemindersResult getRemindersByTaskId(String taskId) async {
//     try {
//       final result = await localDataSource.getRemindersByTaskId(taskId);

//       return result.fold(
//         (failure) => Left(failure),
//         (models) => Right(models.map((m) => m.toEntity()).toList()),
//       );
//     } catch (e) {
//       return Left(CacheFailure('Error fetching task reminders: $e'));
//     }
//   }

//   @override
//   RemindersResult getRemindersBySessionId(String sessionId) async {
//     try {
//       final result = await localDataSource.getRemindersBySessionId(sessionId);

//       return result.fold(
//         (failure) => Left(failure),
//         (models) => Right(models.map((m) => m.toEntity()).toList()),
//       );
//     } catch (e) {
//       return Left(CacheFailure('Error fetching session reminders: $e'));
//     }
//   }

//   @override
//   ResultVoid toggleReminderActive(String reminderId, bool isActive) async {
//     try {
//       final result = await localDataSource.getReminderById(reminderId);

//       return await result.fold((failure) async => Left(failure), (model) async {
//         if (model == null) {
//           return Left(CacheFailure('Reminder not found: $reminderId'));
//         }

//         final updated = model.copyWith(isActive: isActive);

//         final localResult = await localDataSource.cacheReminder(updated);

//         if (localResult.isLeft()) {
//           return localResult;
//         }

//         await remoteDataSource.updateReminder(updated);

//         return const Right(null);
//       });
//     } catch (e) {
//       return Left(CacheFailure('Error toggling reminder: $e'));
//     }
//   }
// }

import 'package:dartz/dartz.dart';
import 'package:smart_study_plan/features/reminder/domain/entities/reminder.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_datasource.dart';
import '../datasources/reminder_remote_datasource.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource localDataSource;
  final ReminderRemoteDataSource remoteDataSource;

  ReminderRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  // ---------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------
  @override
  ReminderResult createReminder(Reminder reminder) async {
    try {
      final model = ReminderModel.fromEntity(reminder);

      final localResult = await localDataSource.cacheReminder(model);

      if (localResult.isLeft()) {
        return localResult.fold(
          (failure) => Left(failure),
          (_) => Left(CacheFailure('Local save failed')),
        );
      }

      // remote is non-blocking
      await remoteDataSource.createReminder(model);

      return Right(reminder);
    } catch (e) {
      return Left(CacheFailure('Create reminder failed: $e'));
    }
  }

  // ---------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------
  @override
  ReminderResult updateReminder(Reminder reminder) async {
    try {
      final model = ReminderModel.fromEntity(reminder);

      // 1️⃣ Save locally
      final localResult = await localDataSource.cacheReminder(model);

      if (localResult.isLeft()) {
        return localResult.fold(
          (failure) => Left(failure),
          (_) => Left(CacheFailure('Local update failed')),
        );
      }

      // 2️⃣ Update remote (non-blocking)
      await remoteDataSource.updateReminder(model);

      // 3️⃣ Return entity (NOT void)
      return Right(reminder);
    } catch (e) {
      return Left(CacheFailure('Update reminder failed: $e'));
    }
  }

  // ---------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------
  @override
  ResultVoid deleteReminder(String reminderId) async {
    try {
      final localResult = await localDataSource.deleteReminder(reminderId);
      if (localResult.isLeft()) return localResult;

      await remoteDataSource.deleteReminder(reminderId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Delete reminder failed: $e'));
    }
  }

  // ---------------------------------------------------------
  // GET BY ID
  // ---------------------------------------------------------
  @override
  Future<Either<Failure, Reminder?>> getReminderById(String reminderId) async {
    try {
      final localResult = await localDataSource.getReminderById(reminderId);

      return await localResult.fold((failure) async {
        final remoteResult = await remoteDataSource.getReminderById(reminderId);

        return remoteResult.fold(
          (f) => Left(f),
          (model) => Right(model?.toEntity()),
        );
      }, (model) => Right(model?.toEntity()));
    } catch (e) {
      return Left(CacheFailure('Get reminder failed: $e'));
    }
  }

  // ---------------------------------------------------------
  // GET BY USER
  // ---------------------------------------------------------
  @override
  RemindersResult getRemindersByUserId(String userId) async {
    try {
      final result = await localDataSource.getByUser(userId);

      return result.fold(
        (f) => Left(f),
        (models) => Right(models.map((e) => e.toEntity()).toList()),
      );
    } catch (e) {
      return Left(CacheFailure('Fetch reminders failed: $e'));
    }
  }

  // ---------------------------------------------------------
  // GET BY TASK
  // ---------------------------------------------------------
  @override
  RemindersResult getRemindersByTaskId(String taskId) async {
    try {
      final result = await localDataSource.getByTask(taskId);

      return result.fold(
        (f) => Left(f),
        (models) => Right(models.map((e) => e.toEntity()).toList()),
      );
    } catch (e) {
      return Left(CacheFailure('Fetch task reminders failed: $e'));
    }
  }

  // ---------------------------------------------------------
  // GET BY SESSION
  // ---------------------------------------------------------
  @override
  RemindersResult getRemindersBySessionId(String sessionId) async {
    try {
      final result = await localDataSource.getBySession(sessionId);

      return result.fold(
        (f) => Left(f),
        (models) => Right(models.map((e) => e.toEntity()).toList()),
      );
    } catch (e) {
      return Left(CacheFailure('Fetch session reminders failed: $e'));
    }
  }

  // ---------------------------------------------------------
  // TOGGLE ACTIVE (USED BY NOTIFICATION)
  // ---------------------------------------------------------
  @override
  ResultVoid toggleReminderActive(String reminderId, bool isActive) async {
    try {
      final result = await localDataSource.getReminderById(reminderId);

      return await result.fold((failure) async => Left(failure), (model) async {
        if (model == null) {
          return Left(CacheFailure('Reminder not found'));
        }

        final updated = model.copyWith(
          isActive: isActive,
          status: isActive ? model.status : 'done',
        );

        final localResult = await localDataSource.cacheReminder(updated);

        if (localResult.isLeft()) return localResult;

        await remoteDataSource.updateReminder(updated);

        return const Right(null);
      });
    } catch (e) {
      return Left(CacheFailure('Toggle reminder failed: $e'));
    }
  }
}
