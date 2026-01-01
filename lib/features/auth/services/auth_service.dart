import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:tracky_mobile/core/services/storage_service.dart';
import 'package:tracky_mobile/features/auth/models/user_model.dart';

class AuthService {
  static const List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'Kwame Asante',
      'email': 'kwame@example.com',
      'phone': '+233244123456',
      'password': '12345678',
      'role': 'miner',
      'location': 'Obuasi, Ashanti Region',
      'minerStatus': 'active',
    },
    {
      'id': '2',
      'name': 'Akosua Mensah',
      'email': 'akosua@goldbod.gov.gh',
      'phone': '+233244654321',
      'password': 'official123',
      'role': 'official',
      'location': 'Accra',
    },
    {
      'id': '3',
      'name': 'Kofi Adjei',
      'email': 'kofi.miner@gmail.com',
      'phone': '+233244987654',
      'password': 'miner456',
      'role': 'miner',
      'location': 'Tarkwa, Western Region',
      'minerStatus': 'active',
    },
  ];

  Future<AuthResult> login(
    String emailOrPhone,
    String password,
    UserRole role,
  ) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay

    try {
      final user = _mockUsers.firstWhere(
        (u) =>
            (u['email'] == emailOrPhone || u['phone'] == emailOrPhone) &&
            u['password'] == password &&
            u['role'] == role.name,
      );

      final userModel = UserModel(
        id: user['id'],
        name: user['name'],
        email: user['email'],
        phone: user['phone'],
        role: UserRole.values.firstWhere((e) => e.name == user['role']),
        location: user['location'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        minerStatus: user['minerStatus'] != null
            ? MinerStatus.values.firstWhere(
                (e) => e.name == user['minerStatus'],
              )
            : null,
      );

      // Generate mock JWT token
      final token = _generateMockToken(userModel);

      // Save to local storage
      await StorageService.saveToken(token);
      await StorageService.saveUserRole(role.name);
      await StorageService.saveUserData(userModel.toJson());

      return AuthResult.success(userModel, token);
    } catch (e) {
      return AuthResult.error('Invalid credentials or role mismatch');
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
    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay

    try {
      // Check if user already exists
      final existingUser = _mockUsers.where(
        (u) => u['email'] == email || u['phone'] == phone,
      );

      if (existingUser.isNotEmpty) {
        return AuthResult.error('User with this email or phone already exists');
      }

      final userId = (Random().nextInt(9000) + 1000).toString();
      final userModel = UserModel(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        role: role,
        location: location,
        createdAt: DateTime.now(),
        minerStatus: role == UserRole.miner ? MinerStatus.pending : null,
      );

      // Generate mock JWT token
      final token = _generateMockToken(userModel);

      // Save to local storage
      await StorageService.saveToken(token);
      await StorageService.saveUserRole(role.name);
      await StorageService.saveUserData(userModel.toJson());

      return AuthResult.success(userModel, token);
    } catch (e) {
      return AuthResult.error('Failed to create account: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await StorageService.logout();
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

  String _generateMockToken(UserModel user) {
    final header = base64Encode(
      utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})),
    );

    final payload = base64Encode(
      utf8.encode(
        jsonEncode({
          'sub': user.id,
          'email': user.email,
          'role': user.role.name,
          'iat': DateTime.now().millisecondsSinceEpoch,
          'exp': DateTime.now()
              .add(const Duration(days: 30))
              .millisecondsSinceEpoch,
        }),
      ),
    );

    final signature = base64Encode(utf8.encode('mock_signature_${user.id}'));

    return '$header.$payload.$signature';
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

  factory AuthResult.error(String error) {
    return AuthResult._(success: false, error: error);
  }
}
