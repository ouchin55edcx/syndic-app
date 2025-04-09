import 'package:flutter/material.dart';

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String relatedTo;
  final String relatedId;
  final String? pdfUrl;
  final bool read;
  final String createdAt;
  final String updatedAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.relatedTo,
    required this.relatedId,
    this.pdfUrl,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      relatedTo: json['relatedTo'] ?? '',
      relatedId: json['relatedId'] ?? '',
      pdfUrl: json['pdfUrl'],
      read: json['read'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'relatedTo': relatedTo,
      'relatedId': relatedId,
      'pdfUrl': pdfUrl,
      'read': read,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper method to get icon based on notification type
  IconData get icon {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
      default:
        return Icons.info;
    }
  }

  // Helper method to get color based on notification type
  Color get color {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
      default:
        return Colors.blue;
    }
  }
}

String formatAmount(double amount) {
  return '${amount.toStringAsFixed(2)} DH';
}
