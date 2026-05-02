import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _baseUrl = 'http://localhost:8000';

  static Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final name = data['name'];
        await saveToken(token);
        await saveUserEmail(email);
        if (name != null) {
          await saveUserName(name);
        }
        return token;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<String> register(String name, String email, String password, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Handle case where token might not be in response
        final token = data['token'] ?? 'token_${DateTime.now().millisecondsSinceEpoch}';
        await saveToken(token);
        await saveUserName(name);
        await saveUserEmail(email);
        return token;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
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

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  static Future<Map<String, dynamic>> getWeather(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/weather?location=$location'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      throw Exception('Weather API error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getTodayTests() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/today-tests'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tests = List<Map<String, dynamic>>.from(data['tests'] ?? []);
        return tests;
      } else {
        throw Exception('Failed to fetch today tests');
      }
    } catch (e) {
      throw Exception('Today tests API error: $e');
    }
  }

  static Future<Map<String, dynamic>> getPassport() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/passport'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch passport data');
      }
    } catch (e) {
      throw Exception('Passport API error: $e');
    }
  }
}
