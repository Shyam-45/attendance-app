import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// class AuthService {
//   static Future<Map<String, dynamic>> login(
//     String email,
//     String password,
//   ) async {
//     await Future.delayed(const Duration(seconds: 1));

//     // debugPrint('✅ Returning hardcoded login response');
//     return {
//       'token': 'random_token_abc123',
//       'user': {
//         'name': 'Shyam',
//         'userId': 'U123456',
//         'designation': 'Officer',
//         'officerType': 'Regular',
//         'mobile': '1234567890',
//         'boothNumber': '54321',
//         'boothName': 'Random Location',
//       },
//     };
//   }
// }

class AuthService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/blo/login');
    // debugPrint('🔐 Sending login request to: $url');
    // debugPrint('📤 Request body: { email: $email, password: $password }');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': email, 'password': password}),
      );

      // debugPrint('📥 Response status: ${response.statusCode}');
      // debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // debugPrint('✅ Login successful. Token: ${data['token']}');
        return {'token': data['token'], 'user': data['user']};
      } else {
        // debugPrint('❌ Login failed with status ${response.statusCode}');
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      // debugPrint('💥 Error during login: $e');
      rethrow;
    }
  }
}
