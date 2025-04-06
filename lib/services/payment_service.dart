import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import '../models/charge_model.dart';

class PaymentService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<Map<String, dynamic>> makePayment(
    Map<String, dynamic> paymentData,
    String token,
  ) async {
    try {
      debugPrint('Making payment with token: $token');
      debugPrint('Authorization header: Bearer $token');
      debugPrint('Request data: ${jsonEncode(paymentData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(paymentData),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Paiement enregistré avec succès',
          'payment': responseData['payment'] != null
              ? Payment.fromJson(responseData['payment'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Échec de l\'enregistrement du paiement',
        };
      }
    } catch (e) {
      debugPrint('Make payment error: $e');
      return {
        'success': false,
        'message': 'Une erreur est survenue. Veuillez réessayer: $e',
      };
    }
  }

  Future<Map<String, dynamic>> confirmPayment(
    String paymentId,
    Map<String, dynamic> confirmationData,
    String token,
  ) async {
    try {
      debugPrint('Confirming payment $paymentId with token: $token');
      debugPrint('Authorization header: Bearer $token');
      debugPrint('Request data: ${jsonEncode(confirmationData)}');

      final response = await http.put(
        Uri.parse('$baseUrl/payments/$paymentId/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(confirmationData),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Payment? confirmedPayment;
        try {
          if (responseData['payment'] != null) {
            confirmedPayment = Payment.fromJson(responseData['payment']);
            debugPrint('Successfully parsed confirmed payment: ${confirmedPayment.id}');
          }
        } catch (e) {
          debugPrint('Error parsing payment data: $e');
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Paiement confirmé avec succès',
          'payment': confirmedPayment,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Échec de la confirmation du paiement',
        };
      }
    } catch (e) {
      debugPrint('Confirm payment error: $e');
      return {
        'success': false,
        'message': 'Une erreur est survenue. Veuillez réessayer: $e',
      };
    }
  }

  Future<Map<String, dynamic>> rejectPayment(
    String paymentId,
    Map<String, dynamic> rejectionData,
    String token,
  ) async {
    try {
      debugPrint('Rejecting payment $paymentId with token: $token');
      debugPrint('Authorization header: Bearer $token');
      debugPrint('Request data: ${jsonEncode(rejectionData)}');

      final response = await http.put(
        Uri.parse('$baseUrl/payments/$paymentId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(rejectionData),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Paiement rejeté avec succès',
          'payment': responseData['payment'] != null
              ? Payment.fromJson(responseData['payment'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Échec du rejet du paiement',
        };
      }
    } catch (e) {
      debugPrint('Reject payment error: $e');
      return {
        'success': false,
        'message': 'Une erreur est survenue. Veuillez réessayer: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getPaymentHistory(
    String proprietaireId,
    String token,
  ) async {
    try {
      debugPrint('Fetching payment history for proprietaire $proprietaireId with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/payments/history/$proprietaireId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> paymentsJson = responseData['payments'] ?? [];
        final List<Payment> payments = paymentsJson
            .map((json) => Payment.fromJson(json))
            .toList();

        List<Charge> charges = [];
        if (responseData['charges'] != null) {
          try {
            final List<dynamic> chargesJson = responseData['charges'] as List<dynamic>;
            for (var chargeData in chargesJson) {
              try {
                if (chargeData is Map<String, dynamic>) {
                  charges.add(Charge.fromJson(chargeData));
                }
              } catch (e) {
                debugPrint('Error parsing individual charge: $e');
              }
            }
            debugPrint('Successfully parsed ${charges.length} charges');
          } catch (e) {
            debugPrint('Error parsing charges list: $e');
          }
        }

        return {
          'success': true,
          'proprietaire': responseData['proprietaire'],
          'payments': payments,
          'charges': charges,
          'totalPaid': responseData['totalPaid'] ?? 0.0,
          'totalDue': responseData['totalDue'] ?? 0.0,
          'startDate': responseData['startDate'],
          'endDate': responseData['endDate'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Échec de la récupération de l\'historique des paiements',
        };
      }
    } catch (e) {
      debugPrint('Get payment history error: $e');
      return {
        'success': false,
        'message': 'Une erreur est survenue. Veuillez réessayer: $e',
      };
    }
  }

  // Get all payments (syndic only)
  Future<Map<String, dynamic>> getAllPayments(String token) async {
    try {
      debugPrint('Fetching all payments with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> paymentsJson = responseData['payments'] ?? [];
        final List<Payment> payments = paymentsJson
            .map((json) => Payment.fromJson(json))
            .toList();

        return {
          'success': true,
          'count': responseData['count'] ?? payments.length,
          'payments': payments,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch payments',
        };
      }
    } catch (e) {
      debugPrint('Get all payments error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Get all pending payments (syndic only)
  Future<Map<String, dynamic>> getPendingPayments(String token) async {
    try {
      debugPrint('Fetching pending payments with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/payments/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> paymentsJson = responseData['payments'] ?? [];
        final List<Payment> payments = paymentsJson
            .map((json) => Payment.fromJson(json))
            .toList();

        return {
          'success': true,
          'payments': payments,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Échec de la récupération des paiements en attente',
        };
      }
    } catch (e) {
      debugPrint('Get pending payments error: $e');
      return {
        'success': false,
        'message': 'Une erreur est survenue. Veuillez réessayer: $e',
      };
    }
  }
}
