import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationRequiredScreen extends StatefulWidget {
  const LocationRequiredScreen({super.key});

  @override
  State<LocationRequiredScreen> createState() =>
      _PermissionRequiredScreenState();
}

class _PermissionRequiredScreenState extends State<LocationRequiredScreen>
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
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse && !_hasNavigatedBack) {
      _hasNavigatedBack = true;
      debugPrint("✅ Background location granted → Returning to splash");
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      debugPrint("🔴 Still missing location permission");
    }
  }

  Future<void> _openSettings() async {
    await Geolocator.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("📱 Location permissionscreen shown");
    return PopScope(
      canPop: false,
      child: Scaffold(
        // title: const Text("Allow 'Always' for location")
        appBar: AppBar(automaticallyImplyLeading: false),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "To continue, you must allow background location access:\n\n"
                "Go to App Settings → Permissions → Location → While in use",
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
