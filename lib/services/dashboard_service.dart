import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardService {
  final String baseUrl = 'http://localhost:3000/api';

  // Récupérer les statistiques du tableau de bord
  Future<Map<String, dynamic>> getDashboardStats(String token) async {
    try {
      debugPrint('Fetching dashboard stats with token: $token');
      
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/dashboard'),
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
          'stats': responseData['stats'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Échec de la récupération des statistiques',
        };
      }
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      return {
        'success': false,
        'message': 'Une erreur est survenue: $e',
      };
    }
  }
}
