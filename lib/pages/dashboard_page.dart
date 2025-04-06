import 'package:flutter/material.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/calendar_widget.dart';
import 'notifications_page.dart'; // Assurez-vous d'importer NotificationsPage
import '../widgets/bar_chart_widget.dart';
import '../widgets/user_avatar.dart';
import '../widgets/NotificationBell.dart'; // Import du UserAvatar
import 'UserProfilePage.dart'; // Import de la page de profil utilisateur

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Tableau de bord",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Spacer(), // Ajoute un espace flexible entre le titre et les icônes
            SizedBox(width: 20), // Ajoute un petit espace entre les icônes
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()), // Redirige vers NotificationsPage
                );
              },
              child: NotificationBell(), // Icône de notification avec 3 notifications
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()),
                );
              },
              child: UserAvatar(), // Utilisation de textSize de 18
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard('Montant total des impayés', PieChartWidget()),
            SizedBox(height: 20),
            _buildCard('Prochaines assemblées', CalendarWidget()),
            SizedBox(height: 20),
            _buildCard('Dépenses mensuelles vs Budget', BarChartWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 46, 45, 45), // Changer la couleur du titre en noir
            ),
          ),
          SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
