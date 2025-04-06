import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SalomonBottomBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          SalomonBottomBarItem(icon: Icon(Icons.home), title: Text("Home"), selectedColor: Colors.blue),
          SalomonBottomBarItem(icon: Icon(Icons.chat_bubble), title: Text("Messages"), selectedColor: Colors.blue),
          SalomonBottomBarItem(icon: Icon(Icons.calendar_today), title: Text("Réunion"), selectedColor: Colors.blue),
          SalomonBottomBarItem(icon: Icon(Icons.business), title: Text("Propriétaires"), selectedColor: Colors.blue), // Ajout correct ici
          SalomonBottomBarItem(icon: Icon(Icons.settings), title: Text("Settings"), selectedColor: Colors.blue),
        ],
      ),
    );
  }
}
