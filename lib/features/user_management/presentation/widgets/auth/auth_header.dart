import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using a column that fills width to ensure centering works well
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo is already handled beautifully in Splash/Auth commonality,
        // but here we make it responsive
        Container(
          height: 80.h, // Increased size for impact
          width: 80.h,
          margin: EdgeInsets.only(bottom: 24.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24.r),
          ),
          padding: EdgeInsets.all(16.r),
          child: Image.asset('assets/logo/app_logo.png'),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            // Larger headline
            fontWeight: FontWeight.w800,
            fontSize: 28.sp,
            letterSpacing: -0.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 16.sp,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: 48.h), // More breathability
      ],
    );
  }
}
