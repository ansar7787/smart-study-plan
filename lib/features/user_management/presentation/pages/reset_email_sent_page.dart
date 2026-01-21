import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/auth/auth_card.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/auth/auth_scaffold.dart';

class ResetEmailSentPage extends StatelessWidget {
  const ResetEmailSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using AuthScaffold for consistency
    return AuthScaffold(
      child: AuthCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 64.sp,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'Check your email',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'We’ve sent a password reset link to your email address.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 16.sp,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 48.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () => context.goNamed(AppRouteNames.login),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 2,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
                child: Text(
                  'Back to login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h), // Bottom spacing
          ],
        ),
      ),
    );
  }
}
