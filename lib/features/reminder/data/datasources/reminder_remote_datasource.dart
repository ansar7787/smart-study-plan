import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../models/reminder_model.dart';

abstract class ReminderRemoteDataSource {
  ReminderVoid createReminder(ReminderModel reminder);
  ReminderVoid updateReminder(ReminderModel reminder);
  ReminderVoid deleteReminder(String reminderId);

  Future<Either<Failure, ReminderModel?>> getReminderById(String reminderId);

  Future<Either<Failure, List<ReminderModel>>> getRemindersByUserId(
    String userId,
  );
}

class ReminderRemoteDataSourceImpl implements ReminderRemoteDataSource {
  final FirebaseFirestore firestore;

  ReminderRemoteDataSourceImpl({required this.firestore});

  static const _collection = 'reminders';

  // --------------------------------------------------
  // CREATE
  // --------------------------------------------------
  @override
  ReminderVoid createReminder(ReminderModel reminder) async {
    try {
      await firestore
          .collection(_collection)
          .doc(reminder.id)
          .set(reminder.toJson());
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure('Create reminder failed: $e'));
    }
  }

  // --------------------------------------------------
  // UPDATE
  // --------------------------------------------------
  @override
  ReminderVoid updateReminder(ReminderModel reminder) async {
    try {
      await firestore
          .collection(_collection)
          .doc(reminder.id)
          .update(reminder.toJson());
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure('Update reminder failed: $e'));
    }
  }

  // --------------------------------------------------
  // DELETE
  // --------------------------------------------------
  @override
  ReminderVoid deleteReminder(String reminderId) async {
    try {
      await firestore.collection(_collection).doc(reminderId).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure('Delete reminder failed: $e'));
    }
  }

  // --------------------------------------------------
  // GET BY ID
  // --------------------------------------------------
  @override
  Future<Either<Failure, ReminderModel?>> getReminderById(
    String reminderId,
  ) async {
    try {
      final doc = await firestore.collection(_collection).doc(reminderId).get();

      if (!doc.exists) {
        return const Right(null);
      }

      return Right(ReminderModel.fromJson(doc.data()!));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure('Get reminder failed: $e'));
    }
  }

  // --------------------------------------------------
  // GET BY USER
  // --------------------------------------------------
  @override
  Future<Either<Failure, List<ReminderModel>>> getRemindersByUserId(
    String userId,
  ) async {
    try {
      final query = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('reminderTime', descending: true)
          .get();

      final reminders = query.docs
          .map((doc) => ReminderModel.fromJson(doc.data()))
          .toList();

      return Right(reminders);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure('Fetch reminders failed: $e'));
    }
  }
}
