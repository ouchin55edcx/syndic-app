import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/proprietaire_profile_model.dart';

class ProprietaireService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<Map<String, dynamic>> createProprietaire(
    Map<String, dynamic> proprietaireData,
    String token,
  ) async {
    try {
      debugPrint('Creating proprietaire with token: $token');
      debugPrint('Authorization header: Bearer $token');
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

  Future<Map<String, dynamic>> getMyProprietaires(String token) async {
    try {
      // Debug token format
      debugPrint('Original token: $token');
      final cleanToken = token.replaceAll('Bearer ', '');
      debugPrint('Cleaned token: $cleanToken');
      
      // Debug request details
      final uri = Uri.parse('$baseUrl/proprietaires');
      debugPrint('Request URI: $uri');
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $cleanToken',
      };
      debugPrint('Request headers: $headers');

      // Make the request
      final response = await http.get(uri, headers: headers);

      // Debug response
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response headers: ${response.headers}');
      debugPrint('Response body: ${response.body}');

      // Parse response
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      debugPrint('Parsed response data: $responseData');

      if (response.statusCode == 200) {
        // Debug proprietaires count
        final proprietaires = responseData['proprietaires'] ?? [];
        debugPrint('Number of proprietaires received: ${proprietaires.length}');
        
        // Debug first proprietaire if available
        if (proprietaires.isNotEmpty) {
          debugPrint('First proprietaire details: ${proprietaires.first}');
        }

        return {
          'success': true,
          'proprietaires': proprietaires,
        };
      } else {
        debugPrint('Request failed with status: ${response.statusCode}');
        debugPrint('Error message: ${responseData['message']}');
        
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch proprietaires',
        };
      }
    } catch (e, stackTrace) {
      // Enhanced error logging
      debugPrint('Error in getMyProprietaires: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Error type: ${e.runtimeType}');
      
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

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

  // Get proprietaire by ID
  Future<Map<String, dynamic>> getProprietaireById(String proprietaireId, String token) async {
    try {
      debugPrint('Fetching proprietaire $proprietaireId with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/proprietaires/$proprietaireId'),
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
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch proprietaire',
        };
      }
    } catch (e) {
      debugPrint('Get proprietaire by ID error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }
}
