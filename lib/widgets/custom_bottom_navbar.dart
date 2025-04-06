import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isSyndic = userProvider.isSyndic;

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
        items: isSyndic
            ? [
                // Syndic navigation items
                SalomonBottomBarItem(icon: Icon(Icons.home), title: Text("Accueil"), selectedColor: Colors.blue),
                SalomonBottomBarItem(icon: Icon(Icons.calendar_today), title: Text("Planifier"), selectedColor: Colors.blue),
                SalomonBottomBarItem(icon: Icon(Icons.business), title: Text("Propriétaires"), selectedColor: Colors.blue),
                SalomonBottomBarItem(icon: Icon(Icons.euro), title: Text("Charges"), selectedColor: Colors.blue),
                SalomonBottomBarItem(icon: Icon(Icons.payments), title: Text("Paiements"), selectedColor: Colors.blue),
                SalomonBottomBarItem(icon: Icon(Icons.groups), title: Text("Réunions"), selectedColor: Colors.blue),
                SalomonBottomBarItem(icon: Icon(Icons.settings), title: Text("Paramètres"), selectedColor: Colors.blue),
              ]
            : [
                // Proprietaire navigation items
                SalomonBottomBarItem(icon: Icon(Icons.home), title: Text("Accueil"), selectedColor: Colors.blue),
                SalomonBottomBarItem(icon: Icon(Icons.euro), title: Text("Charges"), selectedColor: Colors.green),
                SalomonBottomBarItem(icon: Icon(Icons.receipt), title: Text("Paiements"), selectedColor: Colors.green),
                SalomonBottomBarItem(icon: Icon(Icons.groups), title: Text("Réunions"), selectedColor: Colors.blue),
                SalomonBottomBarItem(icon: Icon(Icons.settings), title: Text("Paramètres"), selectedColor: Colors.blue),
              ],
      ),
    );
  }
}
