import 'package:flutter/material.dart';
import 'LoginPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color primaryColor = Color.fromARGB(255, 64, 66, 69);
  final Color accentColor = Color.fromARGB(255, 75, 160, 173);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              Colors.white,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.only(top: 20),
          children: [
            _buildSectionTitle('Autre'),
            _buildListTile(
              context,
              icon: Icons.help_outline,
              title: 'Aide et support',
              subtitle: 'Guides et assistance',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpPage()),
                );
              },
            ),
            SizedBox(height: 8),
            _buildListTile(
              context,
              icon: Icons.exit_to_app,
              title: 'Déconnexion',
              subtitle: 'Se déconnecter de l\'application',
              onTap: () {
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: accentColor,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Confirmation',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Déconnecter',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}

class HelpPage extends StatelessWidget {
  final Color primaryColor = Color.fromARGB(255, 64, 66, 69);
  final Color accentColor = Color.fromARGB(255, 75, 160, 173);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aide et support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, Colors.white],
            stops: [0.0, 0.2],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Guide d\'utilisation',
                [
                  'Gérer les propriétaires: Ajoutez, modifiez ou supprimez des propriétaires',
                  'Gestion des charges: Créez et suivez les charges de copropriété',
                  'Paiements: Suivez les versements et générez des reçus',
                  'Réunions: Planifiez et gérez les assemblées de copropriété',
                ],
                Icons.book,
              ),
              SizedBox(height: 24),
              _buildSection(
                'Contact Support',
                [
                  'Email: support@syndic-app.com',
                  'Téléphone: +212 5XX-XXXXXX',
                  'Horaires: Lun-Ven, 9h-18h',
                ],
                Icons.contact_support,
              ),
              SizedBox(height: 24),
              _buildSection(
                'FAQ',
                [
                  'Comment ajouter un nouveau propriétaire ?',
                  'Comment générer un rapport de paiement ?',
                  'Comment planifier une réunion ?',
                  'Comment gérer les charges communes ?',
                ],
                Icons.question_answer,
              ),
              SizedBox(height: 24),
              _buildSection(
                'Ressources',
                [
                  'Guide PDF complet',
                  'Tutoriels vidéo',
                  'Documentation technique',
                  'Mises à jour récentes',
                ],
                Icons.library_books,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, IconData sectionIcon) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  sectionIcon,
                  color: accentColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
