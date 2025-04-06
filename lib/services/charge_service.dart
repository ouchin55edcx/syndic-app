import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/charge_model.dart';

class ChargeService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Create a new charge (syndic only)
  Future<Map<String, dynamic>> createCharge(
    Map<String, dynamic> chargeData,
    String token,
  ) async {
    try {
      debugPrint('Creating charge with token: $token');
      debugPrint('Authorization header: Bearer $token');
      debugPrint('Request data: ${jsonEncode(chargeData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/charges'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(chargeData),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Charge créée avec succès',
          'charge': responseData['charge'] != null
              ? Charge.fromJson(responseData['charge'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Échec de la création de la charge',
        };
      }
    } catch (e) {
      debugPrint('Create charge error: $e');
      return {
        'success': false,
        'message': 'Une erreur est survenue. Veuillez réessayer: $e',
      };
    }
  }

  // Get all charges (syndic only)
  Future<Map<String, dynamic>> getAllCharges(String token) async {
    try {
      debugPrint('Fetching all charges with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/charges'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> chargesJson = responseData['charges'] ?? [];
        final List<Charge> charges = chargesJson
            .map((json) => Charge.fromJson(json))
            .toList();

        return {
          'success': true,
          'count': responseData['count'] ?? charges.length,
          'charges': charges,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch charges',
        };
      }
    } catch (e) {
      debugPrint('Get all charges error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Get all charges for a proprietaire
  Future<Map<String, dynamic>> getChargesForProprietaire(
    String proprietaireId,
    String token,
  ) async {
    try {
      debugPrint('Fetching charges for proprietaire $proprietaireId with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/charges/proprietaire/$proprietaireId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> chargesJson = responseData['charges'] ?? [];
        final List<Charge> charges = chargesJson
            .map((json) => Charge.fromJson(json))
            .toList();

        return {
          'success': true,
          'charges': charges,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Échec de la récupération des charges',
        };
      }
    } catch (e) {
      debugPrint('Get charges error: $e');
      return {
        'success': false,
        'message': 'Une erreur est survenue. Veuillez réessayer: $e',
      };
    }
  }

  // Get all charges for an appartement
  Future<Map<String, dynamic>> getChargesForAppartement(
    String appartementId,
    String token,
  ) async {
    try {
      debugPrint('Fetching charges for appartement $appartementId with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/charges/appartement/$appartementId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> chargesJson = responseData['charges'] ?? [];
        final List<Charge> charges = chargesJson
            .map((json) => Charge.fromJson(json))
            .toList();

        return {
          'success': true,
          'charges': charges,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Échec de la récupération des charges',
        };
      }
    } catch (e) {
      debugPrint('Get charges error: $e');
      return {
        'success': false,
        'message': 'Une erreur est survenue. Veuillez réessayer: $e',
      };
    }
  }

  // Generate payment reminder (avis client)
  Future<Map<String, dynamic>> generatePaymentReminder(
    String chargeId,
    Map<String, dynamic> reminderData,
    String token,
  ) async {
    try {
      debugPrint('Generating payment reminder for charge $chargeId with token: $token');
      debugPrint('Authorization header: Bearer $token');
      debugPrint('Request data: ${jsonEncode(reminderData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/payments/reminder/$chargeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(reminderData),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Rappel de paiement généré avec succès',
          'reminder': responseData['reminder'],
          'notification': responseData['notification'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Échec de la génération du rappel de paiement',
        };
      }
    } catch (e) {
      debugPrint('Generate payment reminder error: $e');
      return {
        'success': false,
        'message': 'Une erreur est survenue. Veuillez réessayer: $e',
      };
    }
  }
}
