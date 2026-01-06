import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tracky_mobile/features/auth/models/user_model.dart';
import 'package:tracky_mobile/features/auth/services/auth_service.dart';
import 'package:tracky_mobile/core/network/dio_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AuthService(dioClient);
});

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
      // Signup successful (OTP sent), but NOT authenticated yet
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: null,
      );
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    final success = await _authService.verifyOtp(email, otp);

    if (success) {
      state = state.copyWith(isLoading: false, error: null);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: 'Invalid OTP');
      return false;
    }
  }

  Future<bool> generateOtp(String email) async {
    // We don't set loading state here to keep the UI interactive,
    // or we could set a specific 'isResendingOtp' state if we had it.
    // For now, we'll just return the result.
    final success = await _authService.generateOtp(email);
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
