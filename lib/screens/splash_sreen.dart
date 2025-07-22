import 'package:attendance_app/providers/app_state_provider.dart';
import 'package:attendance_app/screens/home_screen.dart';
import 'package:attendance_app/screens/login_screen.dart';
import 'package:attendance_app/screens/permission_screens/location_required_screen.dart';
import 'package:attendance_app/screens/permission_screens/notification_required_screen.dart';
import 'package:attendance_app/utils/check_location_utils.dart';
import 'package:attendance_app/utils/check_notification_utils.dart';
// import 'package:attendance_app/utils/notification_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    debugPrint("🌊 SplashScreen loading...");
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate splash delay

    final appState = ref.read(appStateProvider);

    if (!appState.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    debugPrint("🔐 User is logged in");

    // Check notification permission
    debugPrint("🔔 Checking notification permission...");
    bool notifGranted = await checkNotificationPermission();
    if (!notifGranted) {
      if (!mounted) return;
      final granted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const NotificationRequiredScreen()),
      );

      if (granted != true) {
        debugPrint("❌ Notifications not granted");
        return;
      }
      debugPrint("✅ Notifications granted after screen");
    }

    // Check location permission
    debugPrint("📍 Checking location permission...");
    bool locationGranted = await checkLocationPermission();
    if (!locationGranted) {
      if (!mounted) return;
      final locGranted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LocationRequiredScreen()),
      );
      if (locGranted != true) {
        debugPrint("❌ Location permission still not granted");
        return;
      }
      debugPrint("✅ Location granted after screen");
    }

    // await scheduleNotificationsForWeek();

    // Navigate to Home
    if (!mounted) return;
    debugPrint("🏠 Navigating to HomeScreen");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            "Checking permissions and logging in...",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
