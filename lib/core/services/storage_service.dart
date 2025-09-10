import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracky_mobile/core/constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic methods
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  static bool getBool(String key) {
    return _prefs?.getBool(key) ?? false;
  }

  static Future<bool> setStringList(String key, List<String> values) async {
    return await _prefs?.setStringList(key, values) ?? false;
  }

  static List<String> getStringList(String key) {
    return _prefs?.getStringList(key) ?? [];
  }

  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  // App specific methods
  static Future<bool> saveToken(String token) async {
    return await setString(AppConstants.userTokenKey, token);
  }

  static String? getToken() {
    return getString(AppConstants.userTokenKey);
  }

  static Future<bool> saveUserRole(String role) async {
    return await setString(AppConstants.userRoleKey, role);
  }

  static String? getUserRole() {
    return getString(AppConstants.userRoleKey);
  }

  static Future<bool> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    return await setString(AppConstants.userDataKey, jsonString);
  }

  static Map<String, dynamic>? getUserData() {
    final jsonString = getString(AppConstants.userDataKey);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> savePackages(List<Map<String, dynamic>> packages) async {
    final jsonString = jsonEncode(packages);
    return await setString(AppConstants.packagesKey, jsonString);
  }

  static List<Map<String, dynamic>> getPackages() {
    final jsonString = getString(AppConstants.packagesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> logout() async {
    await remove(AppConstants.userTokenKey);
    await remove(AppConstants.userRoleKey);
    await remove(AppConstants.userDataKey);
    return true;
  }
}
