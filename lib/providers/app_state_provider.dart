import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/models/app_state.dart';

class AppStateNotifier extends StateNotifier<AppState> {
  final Ref ref;

  AppStateNotifier(this.ref) : super(AppState.initial()) {
    loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
      final prefs = SharedPreferencesAsync();
    final token = await prefs.getString('auth_token');
    final userId = await prefs.getString('user_id'); // ✅
    final disabled = await prefs.getBool('user_disabled_today') ?? false;

    if (token != null && userId != null) {
      state = state.copyWith(
        isLoggedIn: true,
        authToken: token,
        userId: userId, // ✅
        userDisabledToday: disabled,
      );
    }
  }

  Future<void> setLogin(String token, String userId) async {
      final prefs = SharedPreferencesAsync();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId); // ✅
    state = state.copyWith(
      isLoggedIn: true,
      authToken: token,
      userId: userId, // ✅
    );
  }

  Future<void> setTrackingDisabledToday(bool value) async {
      final prefs = SharedPreferencesAsync();
    await prefs.setBool('user_disabled_today', value);
    state = state.copyWith(userDisabledToday: value);
  }

  Future<void> logout() async {
      final prefs = SharedPreferencesAsync();
    await prefs.clear();
    // await ref.read(lastLocationProvider.notifier).clearLocation();

    state = AppState.initial();
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier(ref);
});
