import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/providers/app_state_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UploadService {
  static Future<bool> uploadEntry({
    required File imageFile,
    required double latitude,
    required double longitude,
    required DateTime timeSlot,
    required String token,
    required String userId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    debugPrint("📤 [Mock] Uploading image entry...");
    debugPrint("🗂️ TimeSlot: $timeSlot");
    debugPrint("📍 Location: $latitude, $longitude");
    debugPrint("🖼️ Image path: ${imageFile.path}");
    debugPrint("👤 BLO UserId: $userId");
    debugPrint("🔐 Token: $token");

    // Return mock success
    debugPrint("✅ [Mock] Upload successful.");
    return true;
  }
}

// class UploadService {
//   // static const String baseUrl = "http://192.168.21.251:5000";
//   static final String baseUrl = dotenv.env['BASE_URL']!;

//   static Future<bool> uploadEntry({
//     required File imageFile,
//     required double latitude,
//     required double longitude,
//     required DateTime timeSlot,
//     required String token,
//     required String userId,
//   }) async {
//     final bloUserId = userId;

//     if (bloUserId == null) {
//       debugPrint("❌ BLO UserId not found in SharedPreferences");
//       return false;
//     }

//     final url = Uri.parse("$baseUrl/api/blo/send-image");

//     debugPrint("📤 Uploading image entry...");
//     debugPrint("🗂️ TimeSlot: $timeSlot");
//     debugPrint("📍 Location: $latitude, $longitude");
//     debugPrint("🖼️ Image path: ${imageFile.path}");
//     debugPrint("👤 BLO UserId: $bloUserId");
//     debugPrint("🔐 Token: $token");

//     try {
//       final request = http.MultipartRequest("POST", url)
//         ..headers['Authorization'] = 'Bearer $token'
//         ..fields['latitude'] = latitude.toString()
//         ..fields['longitude'] = longitude.toString()
//         ..fields['bloUserId'] = bloUserId
//         ..fields['timeSlot'] = timeSlot.toIso8601String()
//         ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       debugPrint("📡 Upload response: ${response.statusCode}");
//       debugPrint("📄 Body: ${response.body}");

//       if (response.statusCode == 200) {
//         final body = json.decode(response.body);
//         return body['success'] == true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       debugPrint("❌ Upload failed: $e");
//       return false;
//     }
//   }
// }
