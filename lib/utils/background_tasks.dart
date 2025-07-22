import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:attendance_app/utils/notification_utils.dart';

const weeklyNotifTask = 'schedule_weekly_notifications';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("🚀 WorkManager triggered: $task");

    if (task == weeklyNotifTask) {
      debugPrint("📦 Running weekly notification task...");
      await scheduleNotificationsForWeek();
      debugPrint("✅ Weekly notifications scheduled");
    }

    return Future.value(true);
  });
}

// import 'package:workmanager/workmanager.dart';
// import 'package:attendance_app/utils/notification_utils.dart';

// const weeklyNotifTask = 'schedule_weekly_notifications';

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     if (task == weeklyNotifTask) {
//       await scheduleNotificationsForWeek();
//     }
//     return Future.value(true);
//   });
// }
