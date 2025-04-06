import 'package:flutter/material.dart';

class NotificationBell extends StatelessWidget {
  final double iconSize; // Taille de l'icône
  final Color iconColor; // Couleur de l'icône

  NotificationBell({
    this.iconSize = 26.0, // Taille plus grande par défaut
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.notifications, size: iconSize, color: iconColor);
  }
}
