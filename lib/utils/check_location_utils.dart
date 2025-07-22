import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

Future<bool> checkLocationPermission() async {
  // debugPrint("📍 Checking location permission...");

  LocationPermission permission = await Geolocator.checkPermission();
  // debugPrint("🔍 Initial location permission: $permission");

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    // debugPrint("📍 Requested location permission: $permission");
  }

  if (permission == LocationPermission.deniedForever) {
    // debugPrint("❌ Location permission permanently denied.");
    return false;
  }

  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    // debugPrint("✅ Location permission granted: $permission");
    return true;
  }

  // debugPrint("⚠️ Location permission not granted.");
  return false;
}
