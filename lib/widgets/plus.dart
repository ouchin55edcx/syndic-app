import 'package:flutter/material.dart';

class AddIcon extends StatelessWidget {
  final double iconSize; // Taille de l'icône
  final Color iconColor; // Couleur de l'icône

  AddIcon({
    this.iconSize = 26.0, // Taille par défaut
    this.iconColor = Colors.white, // Couleur par défaut
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.add, size: iconSize, color: iconColor);
  }
}
