import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<bool> checkNotificationPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      final currentStatus = await Permission.notification.status;

      if (currentStatus.isGranted) {
        debugPrint("✅ Notification permission already granted (Android 13+)");
        return true;
      } else if (currentStatus.isPermanentlyDenied) {
        debugPrint("❌ Notification permission permanently denied (Android 13+)");
        return false;
      } else {
        final newStatus = await Permission.notification.request();
        debugPrint("📣 Notification permission result: $newStatus");
        return newStatus.isGranted;
      }
    } else {
      debugPrint("ℹ️ Android < 13 — notification permission not required");
      return true;
    }
  }

  debugPrint("⚠️ Notification permission request skipped (Unsupported Platform)");
  return true;
}
