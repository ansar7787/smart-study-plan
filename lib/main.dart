import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_study_plan/config/ai/ai_config.dart';
import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/config/theme/app_theme.dart';
import 'package:smart_study_plan/core/alarm/alarm_service.dart';
import 'package:smart_study_plan/core/utils/permission_handler.dart';
import 'package:smart_study_plan/di/service_locator.dart';

import 'package:smart_study_plan/features/admin_panel/presentation/bloc/admin_users/admin_users_bloc.dart';
import 'package:smart_study_plan/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:smart_study_plan/features/knowledge/presentation/bloc/knowledge_bloc.dart';
import 'package:smart_study_plan/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:smart_study_plan/features/resources/presentation/bloc/resource_bloc.dart';
import 'package:smart_study_plan/features/subjects/presentation/bloc/subject_bloc.dart';
import 'package:smart_study_plan/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AlarmService.instance.init();
  await askNotificationPermission();
  await setupServiceLocator();

  debugPrint('AI key loaded: ${AiConfig.openAiKey.isNotEmpty}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // ✅ BEST universal baseline
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  getIt<UserBloc>()..add(const CheckAuthStatusEvent()),
            ),
            BlocProvider(create: (_) => getIt<AdminUsersBloc>()),
            BlocProvider(create: (_) => getIt<SubjectBloc>()),
            BlocProvider(create: (_) => getIt<TaskBloc>()),
            BlocProvider(create: (_) => getIt<PlannerBloc>()),
            BlocProvider(create: (_) => getIt<ResourceBloc>()),
            BlocProvider(create: (_) => getIt<ReminderBloc>()),
            BlocProvider(create: (_) => getIt<AnalyticsBloc>()),
            BlocProvider(create: (_) => getIt<KnowledgeBloc>()),
          ],
          child: MaterialApp.router(
            title: 'Smart Study Planner',
            theme: AppTheme.light,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
