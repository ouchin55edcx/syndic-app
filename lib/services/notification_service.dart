import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<Map<String, dynamic>> getNotifications(String token) async {
    try {
      debugPrint('Fetching notifications with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> notificationsJson = responseData['notifications'] ?? [];
        final List<Notification> notifications = notificationsJson
            .map((json) => Notification.fromJson(json))
            .toList();

        return {
          'success': true,
          'count': responseData['count'] ?? notifications.length,
          'notifications': notifications,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch notifications',
        };
      }
    } catch (e) {
      debugPrint('Get notifications error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }

  // Mark a notification as read
  Future<Map<String, dynamic>> markAsRead(String notificationId, String token) async {
    try {
      debugPrint('Marking notification $notificationId as read with token: $token');
      debugPrint('Authorization header: Bearer $token');

      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
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
          'message': responseData['message'] ?? 'Notification marked as read',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to mark notification as read',
        };
      }
    } catch (e) {
      debugPrint('Mark notification as read error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again: $e',
      };
    }
  }
}
