import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tracky_mobile/features/auth/models/user_model.dart';
import 'package:tracky_mobile/features/auth/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);

    if (_authService.isLoggedIn()) {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
        return;
      }
    }

    state = state.copyWith(isLoading: false, isAuthenticated: false);
  }

  Future<bool> login(
    String emailOrPhone,
    String password,
    UserRole role,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.login(emailOrPhone, password, role);

    if (result.success) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
        error: null,
      );
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? location,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signup(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
      location: location,
    );

    if (result.success) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
        error: null,
      );
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
