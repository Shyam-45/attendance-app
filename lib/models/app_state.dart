class AppState {
  final bool isLoggedIn;
  final String? authToken;
  final String? userId;
  final bool isLoading;

  const AppState({
    required this.isLoggedIn,
    required this.authToken,
    required this.userId,
    required this.isLoading,
  });

  AppState copyWith({
    bool? isLoggedIn,
    String? authToken,
    String? userId,
    bool? isLoading,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      authToken: authToken ?? this.authToken,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory AppState.initial() => const AppState(
    isLoggedIn: false,
    authToken: null,
    userId: null,
    isLoading: true,
  );
}
