import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../models/reminder_model.dart';

abstract class ReminderLocalDataSource {
  ResultVoid cacheReminder(ReminderModel reminder);
  ResultVoid deleteReminder(String id);

  Future<Either<Failure, ReminderModel?>> getReminderById(String id);
  Future<Either<Failure, List<ReminderModel>>> getByUser(String userId);
  Future<Either<Failure, List<ReminderModel>>> getByTask(String taskId);
  Future<Either<Failure, List<ReminderModel>>> getBySession(String sessionId);
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  static const boxName = 'reminders';

  @override
  ResultVoid cacheReminder(ReminderModel reminder) async {
    try {
      final box = await Hive.openBox<ReminderModel>(boxName);
      await box.put(reminder.id, reminder);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultVoid deleteReminder(String id) async {
    try {
      final box = await Hive.openBox<ReminderModel>(boxName);
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReminderModel?>> getReminderById(String id) async {
    try {
      final box = await Hive.openBox<ReminderModel>(boxName);
      return Right(box.get(id));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReminderModel>>> getByUser(String userId) async {
    try {
      final box = await Hive.openBox<ReminderModel>(boxName);
      return Right(box.values.where((r) => r.userId == userId).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReminderModel>>> getByTask(String taskId) async {
    try {
      final box = await Hive.openBox<ReminderModel>(boxName);
      return Right(box.values.where((r) => r.taskId == taskId).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReminderModel>>> getBySession(
    String sessionId,
  ) async {
    try {
      final box = await Hive.openBox<ReminderModel>(boxName);
      return Right(box.values.where((r) => r.sessionId == sessionId).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
