import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_study_plan/features/user_management/data/datasources/user_local_datasource.dart';
import 'package:smart_study_plan/features/user_management/data/datasources/user_remote_datasource.dart';
import 'package:smart_study_plan/features/user_management/data/repositories/user_repository_impl.dart';
import 'package:smart_study_plan/features/user_management/domain/repositories/user_repository.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/get_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/login_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/logout_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/register_user.dart';

import '../core/utils/logger.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  AppLogger.d('Setting up service locator...');

  // Firebase Setup
  await Firebase.initializeApp();

  // Hive Setup
  await Hive.initFlutter();

  // Firebase instances
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // Local Datasource
  final localDatasource = UserLocalDatasourceImpl();
  await localDatasource.init();
  getIt.registerSingleton<UserLocalDatasource>(localDatasource);

  // Remote Datasource
  getIt.registerSingleton<UserRemoteDatasource>(
    UserRemoteDatasourceImpl(firebaseAuth, firestore),
  );

  // Repository
  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(
      localDatasource: getIt<UserLocalDatasource>(),
      remoteDatasource: getIt<UserRemoteDatasource>(),
    ),
  );

  // UseCases
  getIt.registerSingleton<RegisterUserUseCase>(
    RegisterUserUseCase(getIt<UserRepository>()),
  );
  getIt.registerSingleton<LoginUserUseCase>(
    LoginUserUseCase(getIt<UserRepository>()),
  );
  getIt.registerSingleton<GetUserUseCase>(
    GetUserUseCase(getIt<UserRepository>()),
  );
  getIt.registerSingleton<LogoutUserUseCase>(
    LogoutUserUseCase(getIt<UserRepository>()),
  );

  // Blocs
  // getIt.registerSingleton<UserBloc>(
  //   UserBloc(
  //     registerUserUseCase: getIt<RegisterUserUseCase>(),
  //     loginUserUseCase: getIt<LoginUserUseCase>(),
  //     getCurrentUserUseCase: getIt<GetUserUseCase>(),
  //     logoutUserUseCase: getIt<LogoutUserUseCase>(),
  //   ),
  // );

  AppLogger.d('Service locator setup complete');
}
