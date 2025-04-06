import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../providers/user_provider.dart';
import 'dashboard_page.dart';
import 'schedule_meeting_page.dart';
import 'messages_page.dart';
import 'OwnersListPage.dart'; // Import de la page des propriétaires
import 'settings_page.dart';
import 'charges_list_page.dart';
import 'payment_history_page.dart';
import 'pending_payments_page.dart';
import 'all_payments_page.dart';
import 'reunions_list_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initPages();
  }

  void _initPages() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bool isSyndic = userProvider.isSyndic;

    if (isSyndic) {
      _pages = [
        DashboardPage(),
        MessagesPage(),
        ScheduleMeetingPage(),
        OwnersListPage(),
        ChargesListPage(),
        AllPaymentsPage(),
        ReunionsListPage(),
        SettingsPage(),
      ];
    } else {
      _pages = [
        DashboardPage(),
        MessagesPage(),
        ChargesListPage(),
        PaymentHistoryPage(),
        ReunionsListPage(),
        SettingsPage(),
      ];
    }
  }

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
