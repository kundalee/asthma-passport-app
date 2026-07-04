import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_models.dart';
import 'api_client.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static Future<ApiResult<LoginResult>> login(String email, String password) async {
    final (statusCode, data) = await ApiClient.send(
      'POST',
      '/user/login',
      body: {'email': email, 'password': password},
    );

    if (statusCode == 200) {
      final result = LoginResult.fromJson(data);
      await saveToken(result.token);
      await saveUserEmail(email);
      await saveUserName(result.userName);
      return ApiResult.success(result);
    }

    return ApiClient.failure(statusCode, data, '登入失敗');
  }

  static Future<ApiResult<LoginResult>> register(String name, String email, String password, String confirmPassword) async {
    final (statusCode, data) = await ApiClient.send(
      'POST',
      '/user/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      },
    );

    if (statusCode == 200) {
      // Registration doesn't return a token, so log in to obtain one.
      return login(email, password);
    }

    return ApiClient.failure(statusCode, data, '註冊失敗');
  }

  static Future<ApiResult<UserProfile>> getProfile() async {
    final (statusCode, data) = await ApiClient.send('GET', '/user/profile', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(UserProfile.fromJson(data['data']));
    }

    return ApiClient.failure(statusCode, data, '無法取得個人資料');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }
}
