// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple wrapper around HTTP requests that can be extended as the project
/// evolves.  The front end components should call methods on this service
/// rather than interacting with `http` directly – this makes it easier to
/// swap in a real backend later or to add authentication headers, error
/// handling, etc.
class ApiService {
  static final ApiService instance = ApiService._init();
  final String baseUrl;

  ApiService._init({this.baseUrl = 'https://api.mamacare.com'});

  Future<http.Response> get(String path, {Map<String, String>? headers}) {
    final url = Uri.parse('$baseUrl$path');
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(String path,
      {Map<String, String>? headers, Object? body}) {
    final url = Uri.parse('$baseUrl$path');
    return http.post(url, headers: headers, body: body);
  }

  Future<http.Response> put(String path,
      {Map<String, String>? headers, Object? body}) {
    final url = Uri.parse('$baseUrl$path');
    return http.put(url, headers: headers, body: body);
  }

  Future<http.Response> delete(String path, {Map<String, String>? headers}) {
    final url = Uri.parse('$baseUrl$path');
    return http.delete(url, headers: headers);
  }

  // Example API call that might be used for authentication; real endpoints
  // would depend on the backend implementation.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/login',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    return jsonDecode(response.body);
  }
}
