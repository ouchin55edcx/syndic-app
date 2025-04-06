import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api';

  static const String SYNDIC = 'syndic';
  static const String PROPRIETAIRE = 'proprietaire';


  Future<Map<String, dynamic>> login(String userType, String email, String password) async {
    try {
      debugPrint('Logging in as $userType with email: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/$userType/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['token'];
        debugPrint('Extracted token from response: $token');

        return {
          'success': true,
          'user': User.fromJson(responseData['user']),
          'token': token,
          'message': responseData['message'] ?? 'Login successful',
          'userType': userType,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return {
        'success': false,
        'message': 'An error occurred during login. Please try again.',
      };
    }
  }

  // Login as syndic
  Future<Map<String, dynamic>> loginAsSyndic(String email, String password) async {
    return login(SYNDIC, email, password);
  }

  // Login as proprietaire
  Future<Map<String, dynamic>> loginAsProprietaire(String email, String password) async {
    return login(PROPRIETAIRE, email, password);
  }
}
