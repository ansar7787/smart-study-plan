import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Transparent wrapper now, full width but constrained for tablets
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 500.w),
      // No more padding here, handled by Scaffold or page
      child: child,
    );
  }
}
