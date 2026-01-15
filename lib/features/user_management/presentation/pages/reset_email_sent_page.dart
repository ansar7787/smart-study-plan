import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/auth/auth_card.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/auth/auth_scaffold.dart';

class ResetEmailSentPage extends StatelessWidget {
  const ResetEmailSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthScaffold(
      child: AuthCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mark_email_read_outlined,
              size: 64,
              color: Color(0xFF4F46E5),
            ),
            const SizedBox(height: 20),
            Text(
              'Check your email',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We’ve sent a password reset link to your email address.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.goNamed(AppRouteNames.login),
                child: const Text(
                  'Back to login',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
