import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/appartement_model.dart';

class AppartementService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<Map<String, dynamic>> getAllAppartements(String token) async {
    try {
      debugPrint('Fetching appartements with token: $token');
      debugPrint('Authorization header: Bearer $token'); 

      final response = await http.get(
        Uri.parse('$baseUrl/appartements'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> appartementsList = responseData['appartements'] ?? [];
        final List<Appartement> appartements = appartementsList
            .map((json) => Appartement.fromJson(json))
            .toList();


        return {
          'success': true,
          'count': responseData['count'] ?? appartements.length,
          'appartements': appartements,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch appartements',
        };
      }
    } catch (e) {
      debugPrint('Get appartements error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }
}
