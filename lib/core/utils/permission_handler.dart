import 'package:permission_handler/permission_handler.dart';

Future<void> askNotificationPermission() async {
  // Only needed Android 13+, but safe to call always
  final status = await Permission.notification.status;
  if (status.isDenied || status.isRestricted) {
    final result = await Permission.notification.request();
    if (!result.isGranted) {
      // Optionally show a dialog/toast telling user to enable from settings
      return;
    }
  }
}
