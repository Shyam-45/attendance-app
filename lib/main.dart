import 'package:attendance_app/screens/home_screen.dart';
import 'package:attendance_app/screens/splash_sreen.dart';
import 'package:attendance_app/utils/background_tasks.dart';
import 'package:attendance_app/utils/notification_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // debugPrint("⏰ Initializing timezone...");
  // tz.initializeTimeZones();

  // debugPrint("🔔 Initializing local notifications...");
  // const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  // const initSettings = InitializationSettings(android: android);
  // await flutterLocalNotificationsPlugin.initialize(initSettings);
  // debugPrint("✅ Local notifications initialized");

  // debugPrint("⚙️ Initializing WorkManager...");
  // await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  // final now = DateTime.now();
  // final nextMonday7AM = DateTime(now.year, now.month, now.day + ((8 - now.weekday) % 7), 7);
  // final initialDelay = nextMonday7AM.difference(now);

  // debugPrint("📆 Scheduling weekly WorkManager task...");
  // await Workmanager().registerPeriodicTask(
  //   'weekly_notification_id',
  //   weeklyNotifTask,
  //   frequency: const Duration(days: 7),
  //   initialDelay: initialDelay.isNegative ? const Duration(seconds: 10) : initialDelay,
  //   constraints: Constraints(
  //     networkType: NetworkType.notRequired,
  //     requiresBatteryNotLow: false,
  //     requiresCharging: false,
  //   ),
  // );
  // debugPrint("✅ Weekly task scheduled");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// import 'package:attendance_app/screens/home_screen.dart';
// import 'package:attendance_app/screens/splash_sreen.dart';
// import 'package:attendance_app/utils/background_tasks.dart';
// import 'package:attendance_app/utils/notification_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize timezone
//   tz.initializeTimeZones();

//   // Initialize local notifications
//   const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//   const initSettings = InitializationSettings(android: android);
//   await flutterLocalNotificationsPlugin.initialize(initSettings);

//   // Initialize WorkManager
//   Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

//   // Register weekly job (runs every Monday 7:00 AM approx.)
//   final now = DateTime.now();
//   final nextMonday7AM = DateTime(now.year, now.month, now.day + ((8 - now.weekday) % 7), 7);

//   final initialDelay = nextMonday7AM.difference(now);
//   Workmanager().registerPeriodicTask(
//     'weekly_notification_id',
//     weeklyNotifTask,
//     frequency: const Duration(days: 7),
//     initialDelay: initialDelay.isNegative ? const Duration(seconds: 10) : initialDelay,
//     constraints: Constraints(
//       networkType: NetworkType.notRequired,
//       requiresBatteryNotLow: false,
//       requiresCharging: false,
//     ),
//   );

//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Attendance App',
//       debugShowCheckedModeBanner: false,
//       home: const SplashScreen(),
//     );
//   }
// }
