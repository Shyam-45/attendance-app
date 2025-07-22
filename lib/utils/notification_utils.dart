import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:attendance_app/utils/time_window_utils.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> scheduleNotificationsForWeek() async {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday

  debugPrint("📆 Scheduling notifications from $startOfWeek");

  for (int i = 0; i <= 5; i++) {
    final date = startOfWeek.add(Duration(days: i));
    debugPrint("📅 Scheduling for: ${date.toLocal()}");
    await scheduleNotificationsForDay(date);
  }
}

Future<void> scheduleNotificationsForDay(DateTime date) async {
  final windows = getTimeWindowsForToday();

  for (int i = 0; i < windows.length; i++) {
    final window = windows[i];
    final notificationTime = DateTime(
      date.year,
      date.month,
      date.day,
      window.start.hour,
      window.start.minute,
    ).subtract(const Duration(minutes: 5));

    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint("⏭️ Skipping past window: ${window.label} at $notificationTime");
      continue;
    }

    final tzTime = tz.TZDateTime.from(notificationTime, tz.local);

    debugPrint("📲 Scheduling notification for ${window.label} at ${tzTime.toLocal()}");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      date.day * 100 + i,
      'Upcoming Upload Window',
      'It’s almost time to submit your entry (${window.label})',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'upload_reminders',
          'Upload Reminders',
          channelDescription: 'Reminds users to upload at correct time windows',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:attendance_app/utils/time_window_utils.dart';
// import 'package:timezone/timezone.dart' as tz;

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> scheduleNotificationsForWeek() async {
//   final now = DateTime.now();
//   final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday

//   for (int i = 0; i <= 5; i++) {
//     final date = startOfWeek.add(Duration(days: i));
//     await scheduleNotificationsForDay(date);
//   }
// }

// Future<void> scheduleNotificationsForDay(DateTime date) async {
//   final windows = getTimeWindowsForToday();

//   for (int i = 0; i < windows.length; i++) {
//     final window = windows[i];
//     final notificationTime = DateTime(
//       date.year,
//       date.month,
//       date.day,
//       window.start.hour,
//       window.start.minute,
//     ).subtract(const Duration(minutes: 5));

//     if (notificationTime.isBefore(DateTime.now())) continue;

//     final tzTime = tz.TZDateTime.from(notificationTime, tz.local);

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       date.day * 100 + i, // Unique ID
//       'Upcoming Upload Window',
//       'It’s almost time to submit your entry (${window.label})',
//       tzTime,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'upload_reminders',
//           'Upload Reminders',
//           channelDescription: 'Reminds users to upload at correct time windows',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.dateAndTime,
//     );
//   }
// }
