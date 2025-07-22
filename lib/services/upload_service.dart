import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/providers/app_state_provider.dart';

class UploadService {
  static const String baseUrl = "http://192.168.21.251:5000";

  /// 🖼️ Upload image entry with time slot + location
  static Future<bool> uploadEntry({
    required File imageFile,
    required double latitude,
    required double longitude,
    required DateTime timeSlot,
    required String token,
    required String userId,
  }) async {
    final bloUserId = userId;

    if (bloUserId == null) {
      print("❌ BLO UserId not found in SharedPreferences");
      return false;
    }

    final url = Uri.parse("$baseUrl/api/blo/send-image");

    print("📤 Uploading image entry...");
    print("🗂️ TimeSlot: $timeSlot");
    print("📍 Location: $latitude, $longitude");
    print("🖼️ Image path: ${imageFile.path}");
    print("👤 BLO UserId: $bloUserId");
    print("🔐 Token: $token");

    try {
      final request = http.MultipartRequest("POST", url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['latitude'] = latitude.toString()
        ..fields['longitude'] = longitude.toString()
        ..fields['bloUserId'] = bloUserId
        ..fields['timeSlot'] = timeSlot.toIso8601String()
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📡 Upload response: ${response.statusCode}");
      print("📄 Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print("❌ Upload failed: $e");
      return false;
    }
  }
}
