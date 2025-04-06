import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'dashboard_page.dart';
import 'schedule_meeting_page.dart';
import 'messages_page.dart';
import 'OwnersListPage.dart'; // Import de la page des propriétaires
import 'settings_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    MessagesPage(),
    ScheduleMeetingPage(),
    OwnersListPage(), // Ajout ici à la bonne position
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Affichage de la page sélectionnée
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
