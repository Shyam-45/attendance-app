import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

/// Attempts to get the current position.
///
/// Uses `location` package to prompt GPS enable dialog,
/// and `geolocator` for permission + fetching current coordinates.
Future<Position?> getCurrentPosition() async {
  try {
    // 🔄 Prompt GPS enable via `location` package
    final loc.Location location = loc.Location();
    bool isGpsEnabled = await location.serviceEnabled();
    if (!isGpsEnabled) {
      isGpsEnabled = await location.requestService(); // 🚀 Prompts GPS enable
      if (!isGpsEnabled) {
        print('❌ User declined to enable GPS.');
        return null;
      }
    }

    // 🔐 Check and request location permissions via Geolocator
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Location permission denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Location permission permanently denied. Please enable from app settings.');
      await Geolocator.openAppSettings();
      return null;
    }

    // 📍 Fetch current position
    Position position = await Geolocator.getCurrentPosition();
    print('📍 Position obtained: $position');
    return position;
  } catch (e) {
    print('❌ Exception while getting location: $e');
    return null;
  }
}
