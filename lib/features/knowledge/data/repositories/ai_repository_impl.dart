import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../datasources/ai_remote_datasource.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/entities/ai_action_result.dart';
import '../../domain/enums/ai_action_type.dart';

import '../../../../features/user_management/data/datasources/user_remote_datasource.dart';
import '../../../../features/user_management/data/models/user_model.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remote;
  final UserRemoteDatasource userRemote;

  AiRepositoryImpl(this.remote, this.userRemote);

  @override
  Future<Either<Failure, AiActionResult>> runAction({
    required String userId,
    required AiActionType action,
    required String input,
  }) async {
    try {
      final userModel = await userRemote.getUser(userId);

      // Check Daily Limit
      final now = DateTime.now();
      final lastActionDate = userModel.lastAiUsageDate;
      int currentUsage = userModel.aiUsageCount;

      final isNewDay =
          lastActionDate == null ||
          now.year != lastActionDate.year ||
          now.month != lastActionDate.month ||
          now.day != lastActionDate.day;

      if (isNewDay) {
        currentUsage = 0;
      }

      const dailyLimit = 20;
      if (currentUsage >= dailyLimit) {
        return Left(
          ServerFailure(
            'Daily AI limit reached ($dailyLimit/day). Please try again tomorrow.',
          ),
        );
      }

      // Run Action
      final result = await remote.runAction(action: action, input: input);

      // If success, increment usage
      return result.fold((l) => Left(l), (r) async {
        await userRemote.updateUser(
          UserModel(
            id: userModel.id,
            email: userModel.email,
            name: userModel.name,
            role: userModel.role,
            photoUrl: userModel.photoUrl,
            createdAt: userModel.createdAt,
            updatedAt: DateTime.now(),
            aiUsageCount: currentUsage + 1,
            lastAiUsageDate: now,
          ),
        );
        return Right(r);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to check AI usage limit'));
    }
  }
}
