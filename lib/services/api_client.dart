import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';
import 'navigation_service.dart';

// Result envelope for API calls: success/failure plus an optional typed
// payload, so callers get a compile-time checked model on success instead
// of stringly-typed map access.
class ApiResult<T> {
  final bool success;
  final String? message;
  final T? data;

  const ApiResult.success([this.data]) : success = true, message = null;

  const ApiResult.failure(this.message) : success = false, data = null;
}

// Shared HTTP helper for AuthService and ApiService.
class ApiClient {
  // Performs the request and decodes the JSON body. Callers interpret the
  // status/body themselves since success shapes differ per endpoint; this
  // centralizes transport concerns (headers, auth, decoding) and network
  // failures, so callers never need their own try/catch: a connection
  // failure/timeout/malformed body comes back as statusCode 0 with a
  // ready-to-display message, same shape as any other error response.
  static Future<(int statusCode, Map<String, dynamic> data)> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    debugPrint('API $method $path body=${_redact(body)}');
    try {
      final headers = {'Content-Type': 'application/json'};
      if (authenticated) {
        final token = await AuthService.getToken();
        headers['Authorization'] = 'Bearer $token';
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final http.Response response;
      if (method == 'GET') {
        response = await http.get(uri, headers: headers);
      } else if (method == 'PUT') {
        response = await http.put(uri, headers: headers, body: jsonEncode(body));
      } else if (method == 'DELETE') {
        response = await http.delete(uri, headers: headers, body: jsonEncode(body));
      } else {
        response = await http.post(uri, headers: headers, body: jsonEncode(body));
      }

      final bodyText = utf8.decode(response.bodyBytes);
      final data = bodyText.isEmpty ? <String, dynamic>{} : jsonDecode(bodyText) as Map<String, dynamic>;
      debugPrint('API $method $path -> ${response.statusCode} $data');
      return (response.statusCode, data);
    } catch (e) {
      debugPrint('API $method $path failed: $e');
      return (0, {'message': '無法連接伺服器，請稍後再試'});
    }
  }

  // Masks password fields so credentials never hit the debug log.
  static Map<String, dynamic>? _redact(Map<String, dynamic>? body) {
    if (body == null) return null;
    return body.map((key, value) => MapEntry(key, key.toLowerCase().contains('password') ? '***' : value));
  }

  // Builds the failure result for a non-success response. For requests that
  // carried a token, a 401 means the stored token is invalid/expired: clears
  // the local session and sends the user back to login, so callers don't
  // each need to handle it. For unauthenticated requests (e.g. login itself)
  // a 401 is just a business-logic error like wrong credentials, not an
  // expired session, so it's surfaced as a normal failure instead.
  static Future<ApiResult<T>> failure<T>(
    int statusCode,
    Map<String, dynamic> data,
    String fallbackMessage, {
    bool authenticated = false,
  }) async {
    if (statusCode == 401 && authenticated) {
      await AuthService.logout();
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      return ApiResult.failure('登入已過期，請重新登入');
    }
    return ApiResult.failure(data['detail'] ?? data['message'] ?? fallbackMessage);
  }
}
