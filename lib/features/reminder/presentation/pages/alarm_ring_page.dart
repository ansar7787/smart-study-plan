import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/di/service_locator.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:smart_study_plan/features/reminder/presentation/bloc/reminder_event.dart';

class AlarmRingPage extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingPage({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context) {
    // 🎨 Theme colors
    const bgColor = Color(0xFF1E1E2C); // Dark Violet/Slate
    const accentColor = Color(0xFF6366F1); // Primary Violet

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // 🔔 BELL ANIMATION
            _RingingBell(color: accentColor),

            const SizedBox(height: 40),

            // 📝 TITLE
            Text(
              alarmSettings.notificationSettings.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                alarmSettings.notificationSettings.body,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(),

            // 🛑 STOP BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: _SlideToStopButton(
                onStop: () async {
                  final reminderId = alarmSettings.payload;
                  await Alarm.stop(alarmSettings.id);

                  if (reminderId != null && reminderId.isNotEmpty) {
                    getIt<ReminderBloc>().add(DeleteReminderEvent(reminderId));
                  }

                  if (context.mounted) {
                    // Navigate back to home or pop
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(AppRouteNames.home);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔔 ANIMATED BELL
class _RingingBell extends StatelessWidget {
  final Color color;

  const _RingingBell({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.alarm, size: 80, color: color)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shake(hz: 4, curve: Curves.easeInOutCubic, duration: 1200.ms)
          .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
    );
  }
}

// 🛑 SLIDE TO STOP (Simulated for now with a big button)
class _SlideToStopButton extends StatelessWidget {
  final VoidCallback onStop;

  const _SlideToStopButton({required this.onStop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: onStop,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444), // Red
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.4),
        ),
        icon: const Icon(Icons.stop_circle_outlined, size: 28),
        label: const Text(
          'STOP ALARM',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
