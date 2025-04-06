import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/proprietaire_profile_model.dart';

class ProprietaireService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Create a new proprietaire (only for syndic)
  Future<Map<String, dynamic>> createProprietaire(
    Map<String, dynamic> proprietaireData,
    String token,
  ) async {
    try {
      debugPrint('Creating proprietaire with token: $token');
      debugPrint('Authorization header: Bearer $token'); // With Bearer prefix
      debugPrint('Request data: ${jsonEncode(proprietaireData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/proprietaires'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(proprietaireData),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Proprietaire created successfully',
          'proprietaire': responseData['proprietaire'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create proprietaire',
        };
      }
    } catch (e) {
      debugPrint('Create proprietaire error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Get all proprietaires for the syndic
  Future<Map<String, dynamic>> getMyProprietaires(String token) async {
    try {
      debugPrint('Fetching proprietaires with token: $token');
      debugPrint('Authorization header: Bearer $token'); // With Bearer prefix

      final response = await http.get(
        Uri.parse('$baseUrl/proprietaires/my-proprietaires'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'proprietaires': responseData['proprietaires'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch proprietaires',
        };
      }
    } catch (e) {
      debugPrint('Get proprietaires error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Get proprietaire profile
  Future<Map<String, dynamic>> getProprietaireProfile(String token) async {
    try {
      debugPrint('Fetching proprietaire profile with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/proprietaires/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'proprietaire': responseData['proprietaire'] != null
              ? ProprietaireProfile.fromJson(responseData['proprietaire'])
              : null,
          'appartement': responseData['appartement'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch proprietaire profile',
        };
      }
    } catch (e) {
      debugPrint('Get proprietaire profile error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Update proprietaire profile
  Future<Map<String, dynamic>> updateProprietaireProfile(
    Map<String, dynamic> profileData,
    String token,
  ) async {
    try {
      debugPrint('Updating proprietaire profile with token: $token');
      debugPrint('Authorization header: Bearer $token');
      debugPrint('Request data: ${jsonEncode(profileData)}');

      final response = await http.put(
        Uri.parse('$baseUrl/proprietaires/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profile updated successfully',
          'proprietaire': responseData['proprietaire'] != null
              ? ProprietaireProfile.fromJson(responseData['proprietaire'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      debugPrint('Update proprietaire profile error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }
}
