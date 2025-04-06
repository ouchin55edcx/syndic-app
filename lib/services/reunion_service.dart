import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/reunion_model.dart';

class ReunionService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<Map<String, dynamic>> createReunion(
    Map<String, dynamic> reunionData,
    String token,
  ) async {
    try {
      debugPrint('Creating reunion with token: $token');
      debugPrint('Authorization header: Bearer $token');
      debugPrint('Request data: ${jsonEncode(reunionData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/reunions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(reunionData),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Reunion created successfully',
          'reunion': responseData['reunion'] != null
              ? Reunion.fromJson(responseData['reunion'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create reunion',
        };
      }
    } catch (e) {
      debugPrint('Create reunion error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Get all reunions
  Future<Map<String, dynamic>> getAllReunions(String token) async {
    try {
      debugPrint('Fetching reunions with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/reunions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> reunionsJson = responseData['reunions'] ?? [];
        final List<Reunion> reunions = reunionsJson
            .map((json) => Reunion.fromJson(json))
            .toList();

        return {
          'success': true,
          'reunions': reunions,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch reunions',
        };
      }
    } catch (e) {
      debugPrint('Get reunions error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Invite proprietaires to a reunion
  Future<Map<String, dynamic>> inviteProprietaires(
    String reunionId,
    List<String> proprietaireIds,
    String token,
  ) async {
    try {
      debugPrint('Inviting proprietaires to reunion $reunionId with token: $token');
      debugPrint('Authorization header: Bearer $token');
      debugPrint('Proprietaire IDs: $proprietaireIds');

      final response = await http.post(
        Uri.parse('$baseUrl/reunions/$reunionId/invite'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'proprietaireIds': proprietaireIds,
        }),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Proprietaires invited successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to invite proprietaires',
        };
      }
    } catch (e) {
      debugPrint('Invite proprietaires error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Get all reunions for the syndic
  Future<Map<String, dynamic>> getMyReunions(String token) async {
    try {
      debugPrint('Fetching my reunions with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/reunions/my-reunions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> reunionsJson = responseData['reunions'] ?? [];
        final List<Reunion> reunions = reunionsJson
            .map((json) => Reunion.fromJson(json))
            .toList();

        return {
          'success': true,
          'count': responseData['count'] ?? reunions.length,
          'reunions': reunions,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch reunions',
        };
      }
    } catch (e) {
      debugPrint('Get my reunions error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Update proprietaire's invitation status (accept/decline)
  Future<Map<String, dynamic>> updateInvitationStatus(
    String reunionId,
    String status,
    String token,
  ) async {
    try {
      debugPrint('Updating invitation status for reunion $reunionId with token: $token');
      debugPrint('Authorization header: Bearer $token');
      debugPrint('Status: $status');

      final response = await http.put(
        Uri.parse('$baseUrl/reunions/$reunionId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Invitation status updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update invitation status',
        };
      }
    } catch (e) {
      debugPrint('Update invitation status error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Update proprietaire's attendance (present/absent)
  Future<Map<String, dynamic>> updateAttendance(
    String reunionId,
    String proprietaireId,
    String attendance,
    String token,
  ) async {
    try {
      debugPrint('Updating attendance for proprietaire $proprietaireId in reunion $reunionId with token: $token');
      debugPrint('Authorization header: Bearer $token');
      debugPrint('Attendance: $attendance');

      final response = await http.put(
        Uri.parse('$baseUrl/reunions/$reunionId/attendance/$proprietaireId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'attendance': attendance,
        }),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Attendance updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update attendance',
        };
      }
    } catch (e) {
      debugPrint('Update attendance error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Get reunion details including invited proprietaires
  Future<Map<String, dynamic>> getReunionDetails(String reunionId, String token) async {
    try {
      debugPrint('Fetching reunion details for $reunionId with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/reunions/$reunionId'),
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
          'reunion': responseData['reunion'] != null
              ? Reunion.fromJson(responseData['reunion'])
              : null,
          'invitedProprietaires': responseData['invitedProprietaires'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch reunion details',
        };
      }
    } catch (e) {
      debugPrint('Get reunion details error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Get all invitations for a reunion
  Future<Map<String, dynamic>> getReunionInvitations(String reunionId, String token) async {
    try {
      debugPrint('Fetching invitations for reunion $reunionId with token: $token');
      debugPrint('Authorization header: Bearer $token');

      // Use the correct endpoint URL
      final response = await http.get(
        Uri.parse('$baseUrl/reunions/$reunionId/invitations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');

      // Check if the response is valid JSON
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          return {
            'success': true,
            'count': responseData['count'] ?? 0,
            'reunionId': responseData['reunionId'] ?? '',
            'reunionTitle': responseData['reunionTitle'] ?? '',
            'reunionDate': responseData['reunionDate'] ?? '',
            'invitations': responseData['invitations'] ?? [],
          };
        } catch (jsonError) {
          debugPrint('JSON parsing error: $jsonError');
          debugPrint('Response body: ${response.body.substring(0, min(100, response.body.length))}...');

          // Fallback: Use the existing reunion details and create a compatible structure
          return {
            'success': true,
            'count': 0,
            'reunionId': reunionId,
            'reunionTitle': '',
            'reunionDate': '',
            'invitations': [],
          };
        }
      } else {
        debugPrint('Error response body: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to fetch reunion invitations. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Get reunion invitations error: $e');

      // Fallback: Use the existing reunion details endpoint as a workaround
      try {
        final detailsResult = await getReunionDetails(reunionId, token);

        if (detailsResult['success'] && detailsResult['invitedProprietaires'] != null) {
          // Convert the proprietaires list to the expected format
          final List<dynamic> proprietaires = detailsResult['invitedProprietaires'];
          final List<Map<String, dynamic>> invitations = proprietaires.map((proprietaire) {
            return {
              'relationship': {
                'id': proprietaire['id'] ?? '',
                'reunionId': reunionId,
                'proprietaireId': proprietaire['id'] ?? '',
                'status': proprietaire['status'] ?? 'pending',
                'attendance': proprietaire['attendance'] ?? 'pending',
                'notificationSent': true,
                'createdAt': proprietaire['createdAt'] ?? '',
                'updatedAt': proprietaire['updatedAt'] ?? '',
              },
              'proprietaire': proprietaire,
            };
          }).toList();

          return {
            'success': true,
            'count': invitations.length,
            'reunionId': reunionId,
            'reunionTitle': detailsResult['reunion']?.title ?? '',
            'reunionDate': detailsResult['reunion']?.date ?? '',
            'invitations': invitations,
          };
        }
      } catch (fallbackError) {
        debugPrint('Fallback error: $fallbackError');
      }

      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }
}
