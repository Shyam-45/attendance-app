import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

Future<Position?> getCurrentPosition() async {
  try {
    final loc.Location location = loc.Location();
    bool isGpsEnabled = await location.serviceEnabled();
    if (!isGpsEnabled) {
      isGpsEnabled = await location.requestService();
      if (!isGpsEnabled) {
        // debugPrint('❌ User declined to enable GPS.');
        return null;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // debugPrint('❌ Location permission denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // debugPrint('❌ Location permission permanently denied. Please enable from app settings.');
      await Geolocator.openAppSettings();
      return null;
    }

    Position position = await Geolocator.getCurrentPosition();
    // debugPrint('📍 Position obtained: $position');
    return position;
  } catch (e) {
    // debugPrint('❌ Exception while getting location: $e');
    return null;
  }
}
