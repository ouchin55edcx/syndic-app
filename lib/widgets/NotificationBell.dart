import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart' as app_notification;

class NotificationBell extends StatefulWidget {
  final double iconSize; // Taille de l'icône
  final Color iconColor; // Couleur de l'icône
  final VoidCallback? onTap; // Fonction appelée lors du clic sur l'icône

  NotificationBell({
    this.iconSize = 26.0, // Taille plus grande par défaut
    this.iconColor = Colors.white,
    this.onTap,
  });

  @override
  _NotificationBellState createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final result = await _notificationService.getNotifications(token);

        if (result['success']) {
          final notifications = result['notifications'] as List<app_notification.Notification>;
          // Compter les notifications non lues
          int unreadCount = 0;
          for (var notification in notifications) {
            if (notification.read == false) {
              unreadCount++;
            }
          }

          setState(() {
            _unreadCount = unreadCount;
          });
        }
      } catch (e) {
        debugPrint('Error loading notification count: $e');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications, size: widget.iconSize, color: widget.iconColor),
          if (_unreadCount > 0)
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Méthode pour rafraîchir le compteur de notifications
  void refreshCount() {
    _loadUnreadCount();
  }
}
