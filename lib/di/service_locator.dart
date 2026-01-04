import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_study_plan/core/network/network_info.dart';
import 'package:smart_study_plan/features/admin_panel/data/datasources/admin_local_datasource.dart';
import 'package:smart_study_plan/features/admin_panel/data/datasources/admin_remote_datasource.dart';
import 'package:smart_study_plan/features/admin_panel/data/repositories/admin_repository_impl.dart';
import 'package:smart_study_plan/features/admin_panel/domain/repositories/admin_repository.dart';
import 'package:smart_study_plan/features/admin_panel/domain/usecases/delete_user_admin.dart';
import 'package:smart_study_plan/features/admin_panel/domain/usecases/get_admin_stats.dart';
import 'package:smart_study_plan/features/admin_panel/domain/usecases/get_all_users.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/bloc/admin_bloc.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/bloc/admin_dashboard/admin_dashboard_bloc.dart';
import 'package:smart_study_plan/features/admin_panel/presentation/bloc/admin_users/admin_users_bloc.dart';
import 'package:smart_study_plan/features/subjects/data/datasources/subject_local_datasource.dart';
import 'package:smart_study_plan/features/subjects/data/datasources/subject_remote_datasource.dart';
import 'package:smart_study_plan/features/subjects/data/models/subject_model.dart';
import 'package:smart_study_plan/features/subjects/data/repositories/subject_repository_impl.dart';
import 'package:smart_study_plan/features/subjects/domain/repositories/subject_repository.dart';
import 'package:smart_study_plan/features/subjects/domain/usecases/create_subject.dart';
import 'package:smart_study_plan/features/subjects/domain/usecases/delete_subject.dart';
import 'package:smart_study_plan/features/subjects/domain/usecases/get_subjects.dart';
import 'package:smart_study_plan/features/subjects/domain/usecases/update_subject.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_bloc.dart';
import 'package:smart_study_plan/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:smart_study_plan/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:smart_study_plan/features/tasks/data/models/task_model.dart';
import 'package:smart_study_plan/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:smart_study_plan/features/tasks/domain/repositories/task_repository.dart';
import 'package:smart_study_plan/features/tasks/domain/usecases/create_task.dart';
import 'package:smart_study_plan/features/tasks/domain/usecases/delete_task.dart';
import 'package:smart_study_plan/features/tasks/domain/usecases/get_tasks_by_subject.dart';
import 'package:smart_study_plan/features/tasks/domain/usecases/update_task.dart';
import 'package:smart_study_plan/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:smart_study_plan/features/user_management/data/datasources/user_local_datasource.dart';
import 'package:smart_study_plan/features/user_management/data/datasources/user_remote_datasource.dart';
import 'package:smart_study_plan/features/user_management/data/repositories/user_repository_impl.dart';
import 'package:smart_study_plan/features/user_management/domain/repositories/user_repository.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/get_current_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/get_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/login_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/logout_user.dart';
import 'package:smart_study_plan/features/user_management/domain/usecases/register_user.dart';
import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';

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

  // Network
  getIt.registerSingleton<Connectivity>(Connectivity());

  getIt.registerSingleton<NetworkInfo>(
    NetworkInfoImpl(connectivity: getIt<Connectivity>()),
  );

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

  getIt.registerSingleton<GetCurrentUserUseCase>(
    GetCurrentUserUseCase(getIt<UserRepository>()),
  );

  getIt.registerSingleton<LogoutUserUseCase>(
    LogoutUserUseCase(getIt<UserRepository>()),
  );

  // Blocs
  getIt.registerSingleton<UserBloc>(
    UserBloc(
      registerUserUseCase: getIt<RegisterUserUseCase>(),
      loginUserUseCase: getIt<LoginUserUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      logoutUserUseCase: getIt<LogoutUserUseCase>(),
    ),
  );

  // Admin Local Datasource
  final adminLocalDatasource = AdminLocalDatasourceImpl();
  await adminLocalDatasource.init();
  getIt.registerSingleton<AdminLocalDatasource>(adminLocalDatasource);

  // Admin Remote Datasource
  getIt.registerSingleton<AdminRemoteDatasource>(
    AdminRemoteDatasourceImpl(FirebaseFirestore.instance),
  );

  // Admin Repository
  getIt.registerSingleton<AdminRepository>(
    AdminRepositoryImpl(
      remoteDatasource: getIt<AdminRemoteDatasource>(),
      localDatasource: getIt<AdminLocalDatasource>(),
    ),
  );

  // Admin UseCases
  getIt.registerSingleton<GetAllUsersUseCase>(
    GetAllUsersUseCase(getIt<AdminRepository>()),
  );
  getIt.registerSingleton<GetAdminStatsUseCase>(
    GetAdminStatsUseCase(getIt<AdminRepository>()),
  );
  getIt.registerSingleton<DeleteUserAdminUseCase>(
    DeleteUserAdminUseCase(getIt<AdminRepository>()),
  );

  // Admin Bloc
  getIt.registerSingleton<AdminBloc>(
    AdminBloc(
      getAllUsersUseCase: getIt<GetAllUsersUseCase>(),
      getAdminStatsUseCase: getIt<GetAdminStatsUseCase>(),
      deleteUserAdminUseCase: getIt<DeleteUserAdminUseCase>(),
    ),
  );

  // Dashboard bloc
  getIt.registerFactory<AdminDashboardBloc>(
    () =>
        AdminDashboardBloc(getAdminStatsUseCase: getIt<GetAdminStatsUseCase>()),
  );

  // Users bloc
  getIt.registerFactory<AdminUsersBloc>(
    () => AdminUsersBloc(
      getAllUsersUseCase: getIt<GetAllUsersUseCase>(),
      deleteUserAdminUseCase: getIt<DeleteUserAdminUseCase>(),
    ),
  );

  // Hive boxes
  final subjectsBox = await Hive.openBox<SubjectModel>('subjects');
  final tasksBox = await Hive.openBox<TaskModel>('tasks');

  getIt.registerSingleton<Box<SubjectModel>>(subjectsBox);
  getIt.registerSingleton<Box<TaskModel>>(tasksBox);

  // ============ SUBJECT FEATURE ============

  // Remote Datasources
  getIt.registerSingleton<SubjectRemoteDatasource>(
    SubjectRemoteDatasourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  // Local Datasources
  getIt.registerSingleton<SubjectLocalDatasource>(
    SubjectLocalDatasourceImpl(subjectsBox: getIt<Box<SubjectModel>>()),
  );

  // Repository
  getIt.registerSingleton<SubjectRepository>(
    SubjectRepositoryImpl(
      remoteDatasource: getIt<SubjectRemoteDatasource>(),
      localDatasource: getIt<SubjectLocalDatasource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Usecases
  getIt.registerSingleton<GetSubjectsByUserUsecase>(
    GetSubjectsByUserUsecase(repository: getIt<SubjectRepository>()),
  );
  getIt.registerSingleton<CreateSubjectUsecase>(
    CreateSubjectUsecase(repository: getIt<SubjectRepository>()),
  );
  getIt.registerSingleton<UpdateSubjectUsecase>(
    UpdateSubjectUsecase(repository: getIt<SubjectRepository>()),
  );
  getIt.registerSingleton<DeleteSubjectUsecase>(
    DeleteSubjectUsecase(repository: getIt<SubjectRepository>()),
  );

  // BLoC
  getIt.registerSingleton<SubjectBloc>(
    SubjectBloc(
      getSubjectsByUserUsecase: getIt<GetSubjectsByUserUsecase>(),
      createSubjectUsecase: getIt<CreateSubjectUsecase>(),
      updateSubjectUsecase: getIt<UpdateSubjectUsecase>(),
      deleteSubjectUsecase: getIt<DeleteSubjectUsecase>(),
    ),
  );

  // ============ TASK FEATURE ============

  // Remote Datasources
  getIt.registerSingleton<TaskRemoteDatasource>(
    TaskRemoteDatasourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  // Local Datasources
  getIt.registerSingleton<TaskLocalDatasource>(
    TaskLocalDatasourceImpl(tasksBox: getIt<Box<TaskModel>>()),
  );

  // Repository
  getIt.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(
      remoteDatasource: getIt<TaskRemoteDatasource>(),
      localDatasource: getIt<TaskLocalDatasource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Usecases
  getIt.registerSingleton<GetTasksBySubjectUsecase>(
    GetTasksBySubjectUsecase(repository: getIt<TaskRepository>()),
  );
  getIt.registerSingleton<CreateTaskUsecase>(
    CreateTaskUsecase(repository: getIt<TaskRepository>()),
  );
  getIt.registerSingleton<UpdateTaskUsecase>(
    UpdateTaskUsecase(repository: getIt<TaskRepository>()),
  );
  getIt.registerSingleton<DeleteTaskUsecase>(
    DeleteTaskUsecase(repository: getIt<TaskRepository>()),
  );

  // BLoC
  getIt.registerSingleton<TaskBloc>(
    TaskBloc(
      getTasksBySubjectUsecase: getIt<GetTasksBySubjectUsecase>(),
      createTaskUsecase: getIt<CreateTaskUsecase>(),
      updateTaskUsecase: getIt<UpdateTaskUsecase>(),
      deleteTaskUsecase: getIt<DeleteTaskUsecase>(),
    ),
  );

  AppLogger.d('Service locator setup complete');
}
