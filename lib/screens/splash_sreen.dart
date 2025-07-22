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
import 'package:cupertino_icons/cupertino_icons.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B23),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1B23),
              Color(0xFF2D2E3F),
              Color(0xFF1A1B23),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    size: 60,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Attendance Tracker",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Checking permissions and logging in...",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF4F46E5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
