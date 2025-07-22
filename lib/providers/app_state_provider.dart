import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/models/app_state.dart';

class AppStateNotifier extends StateNotifier<AppState> {
  final Ref ref;

  AppStateNotifier(this.ref) : super(AppState.initial()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');

    if (token != null && userId != null) {
      state = state.copyWith(
        isLoggedIn: true,
        authToken: token,
        userId: userId,
      );
    } else {
       state = AppState.initial().copyWith(isLoading: false);
    }
  }

  Future<void> setLogin(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);

    state = state.copyWith(
      isLoggedIn: true,
      authToken: token,
      userId: userId,
    );

    debugPrint('Token saved: $token');
    debugPrint('User ID saved: $userId');
  }

  Future<void> setTrackingDisabledToday(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_disabled_today', value);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.clear();

    state = AppState.initial();
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier(ref);
});
