import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';

class AlarmService {
  AlarmService._();
  static final AlarmService instance = AlarmService._();

  Future<void> init() async {
    try {
      debugPrint('🚀 AlarmService.init()');
      await Alarm.init();
      debugPrint('✅ Alarm service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing alarm: $e');
    }
  }

  Future<bool> scheduleTaskAlarm({
    required String taskId,
    required String taskTitle,
    required String reminderId,
    required DateTime reminderTime,
  }) async {
    try {
      debugPrint('🔔 Scheduling task alarm: $taskTitle at $reminderTime');

      final alarmSettings = AlarmSettings(
        id: taskId.hashCode.abs() % 100000,
        dateTime: reminderTime,
        assetAudioPath: 'assets/sounds/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: true,
        androidFullScreenIntent: true,
        // payload: payload,
        volumeSettings: VolumeSettings.fade(
          volume: 0.8,
          fadeDuration: const Duration(seconds: 3),
        ),
        notificationSettings: NotificationSettings(
          title: '📌 Task Reminder',
          body: taskTitle,
          stopButton: 'Stop',
          icon: 'notification_icon',
          iconColor: Colors.teal,
        ),
      );

      await Alarm.set(alarmSettings: alarmSettings);
      debugPrint('✅ Task alarm scheduled: $taskTitle');
      return true;
    } catch (e) {
      debugPrint('❌ Error scheduling task alarm: $e');
      return false;
    }
  }

  Future<bool> scheduleSessionAlarm({
    required String sessionId,
    required String sessionTitle,
    required String reminderId,
    required DateTime reminderTime,
  }) async {
    try {
      debugPrint('🔔 Scheduling session alarm: $sessionTitle at $reminderTime');

      final alarmSettings = AlarmSettings(
        id: sessionId.hashCode.abs() % 100000,
        dateTime: reminderTime,
        assetAudioPath: 'assets/sounds/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: true,
        androidFullScreenIntent: true,
        // payload: payload,
        volumeSettings: VolumeSettings.fade(
          volume: 0.8,
          fadeDuration: const Duration(seconds: 3),
        ),
        notificationSettings: NotificationSettings(
          title: '🎓 Study Session Reminder',
          body: sessionTitle,
          stopButton: 'Stop',
          icon: 'notification_icon',
          iconColor: Colors.teal,
        ),
      );

      await Alarm.set(alarmSettings: alarmSettings);
      debugPrint('✅ Session alarm scheduled: $sessionTitle');
      return true;
    } catch (e) {
      debugPrint('❌ Error scheduling session alarm: $e');
      return false;
    }
  }

  // 🔴 Stop task alarm
  Future<void> stopTaskAlarm(String taskId) async {
    try {
      final alarmId = taskId.hashCode.abs() % 100000;
      await Alarm.stop(alarmId);
      debugPrint('✅ Task alarm stopped: $taskId');
    } catch (e) {
      debugPrint('❌ Error stopping task alarm: $e');
    }
  }

  // 🔴 Stop session alarm
  Future<void> stopSessionAlarm(String sessionId) async {
    try {
      final alarmId = sessionId.hashCode.abs() % 100000;
      await Alarm.stop(alarmId);
      debugPrint('✅ Session alarm stopped: $sessionId');
    } catch (e) {
      debugPrint('❌ Error stopping session alarm: $e');
    }
  }

  Future<void> cancelAllAlarms() async {
    try {
      await Alarm.stopAll();
      debugPrint('✅ All alarms cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling all alarms: $e');
    }
  }
}
