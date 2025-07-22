class AppState {
  final bool isLoggedIn;
  final bool userDisabledToday;
  final String? authToken;
  final String? userId; // ✅ Added userId
  final bool isLoading;

  const AppState({
    required this.isLoggedIn,
    required this.userDisabledToday,
    required this.authToken,
    required this.userId, // ✅ Constructor param
    required this.isLoading,
  });

  AppState copyWith({
    bool? isLoggedIn,
    bool? userDisabledToday,
    String? authToken,
    String? userId, // ✅ Copy param
    bool? isLoading,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userDisabledToday: userDisabledToday ?? this.userDisabledToday,
      authToken: authToken ?? this.authToken,
      userId: userId ?? this.userId, // ✅ Copy logic
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory AppState.initial() => const AppState(
    isLoggedIn: false,
    userDisabledToday: false,
    authToken: null,
    userId: null, // ✅ Init default
    isLoading: true,
  );
}
