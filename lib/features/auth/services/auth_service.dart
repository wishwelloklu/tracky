import 'dart:async';
import 'dart:developer';
import 'package:tracky_mobile/core/services/notification_service.dart';
import 'package:tracky_mobile/core/services/storage_service.dart';
import 'package:tracky_mobile/features/auth/models/user_model.dart';
import 'package:tracky_mobile/core/network/dio_client.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<AuthResult> login(
    String emailOrPhone,
    String password,
    UserRole role,
  ) async {
    try {
      final deviceToken = await NotificationService().getToken();
      final response = await _dioClient.post(
        '/api/v1/auth/login',
        data: {
          'email': emailOrPhone,
          'password': password,
          'deviceToken': deviceToken,
        },
      );
      log(response.data.toString());
      final token = response.data['data']['token'];
      if (token == null) {
        return AuthResult.error('Login successful but no token received.');
      }

      final userData = response.data['data']['userResponseDto'];
      UserModel userModel;
      if (userData != null) {
        userModel = UserModel.fromJson(userData);
      } else {
        // If user data not returned, we might need another call or assume from token
        // For now, returning error if no user data, or we could fallback to a basic model
        return AuthResult.error('Login successful but no user data received.');
      }

      // Save to local storage
      await StorageService.saveToken(token);
      await StorageService.saveUserRole(role.name);
      await StorageService.saveUserData(userModel.toJson());

      return AuthResult.success(userModel, token);
    } catch (e, stackTrace) {
      log(e.toString(), error: e, stackTrace: stackTrace);
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  Future<AuthResult> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? location,
  }) async {
    try {
      final nameParts = name.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      await _dioClient.post(
        '/api/v1/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phone,
        },
      );

      // Registration successful, OTP sent.
      // We don't have a user or token yet.
      return AuthResult.otpSent();
    } catch (e) {
      log(e.toString(), error: e);
      return AuthResult.error('Signup failed: ${e.toString().split(':').last}');
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.post('/api/v1/auth/logout');
    } catch (_) {
      // Ignore network error on logout
    }
    await StorageService.logout();
  }

  Future<bool> generateOtp(String email) async {
    try {
      await _dioClient.post(
        '/api/v1/auth/generate_otp',
        data: {'email': email},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/auth/verify_otp',
        data: {'email': email, 'otp': otp},
      );

      if (response.isSuccess) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final userData = StorageService.getUserData();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  bool isLoggedIn() {
    return StorageService.isLoggedIn();
  }
}

class AuthResult {
  final bool success;
  final UserModel? user;
  final String? token;
  final String? error;

  AuthResult._({required this.success, this.user, this.token, this.error});

  factory AuthResult.success(UserModel user, String token) {
    return AuthResult._(success: true, user: user, token: token);
  }

  factory AuthResult.otpSent() {
    return AuthResult._(success: true); // Success but no user/token yet
  }

  factory AuthResult.error(String error) {
    return AuthResult._(success: false, error: error);
  }
}
