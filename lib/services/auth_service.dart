import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (password != '1111') {
      return {
        'success': false,
        'message': '密碼錯誤',
      };
    }
    const token = 'fake_token_123';
    await saveToken(token);
    await saveUserEmail(email);
    await saveUserName('王曉明');
    return {
      'success': true,
      'token': token,
      'is_first_login': true,
    };
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String confirmPassword) async {
    await Future.delayed(const Duration(milliseconds: 300));
    const token = 'fake_token_123';
    await saveToken(token);
    await saveUserName(name);
    await saveUserEmail(email);
    return {
      'success': true,
      'token': token,
    };
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
