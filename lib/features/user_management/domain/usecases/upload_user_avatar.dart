import 'dart:io';
import 'package:dartz/dartz.dart';

import '../repositories/user_repository.dart';
import '../../../../core/error/failures.dart';

class UploadUserAvatarUseCase {
  final UserRepository repository;

  UploadUserAvatarUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String userId,
    required File file,
  }) {
    return repository.uploadProfilePhoto(userId: userId, file: file);
  }
}
