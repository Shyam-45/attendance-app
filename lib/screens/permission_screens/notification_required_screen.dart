import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationRequiredScreen extends StatefulWidget {
  const NotificationRequiredScreen({super.key});

  @override
  State<NotificationRequiredScreen> createState() =>
      _NotificationRequiredScreenState();
}

class _NotificationRequiredScreenState extends State<NotificationRequiredScreen>
    with WidgetsBindingObserver {
  bool _hasNavigatedBack = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndReturn();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndReturn();
    }
  }

  Future<void> _checkPermissionAndReturn() async {
    final status = await Permission.notification.status;

    if (status.isGranted && !_hasNavigatedBack) {
      _hasNavigatedBack = true;
      debugPrint("✅ Notification permission granted → Returning");
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      debugPrint("🔴 Still missing notification permission");
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("📱 Notification permission screen shown");
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Allow Notifications"),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_active, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                "To continue, you must allow notification access:\n\n"
                "Go to App Settings → Permissions → Notifications → Allow",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _openSettings,
                icon: const Icon(Icons.settings),
                label: const Text("Open App Settings"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
