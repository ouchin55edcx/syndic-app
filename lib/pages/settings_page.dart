import 'package:flutter/material.dart';
import 'UserProfilePage.dart';
import 'LoginPage.dart';
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true; // État pour les notifications

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        elevation: 0, // Supprimer l'ombre
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255), // Texte noir
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black), // Icônes noirs
      ),
      body: ListView(
        padding: EdgeInsets.all(0),
        children: [
          _buildSectionTitle('Compte'),
          _buildListTile(
            context,
            icon: Icons.account_circle,
            title: 'Profil',
            onTap: () {
              // Naviguer vers la page de profil
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.lock,
            title: 'Sécurité',
            onTap: () {
              // Naviguer vers les paramètres de sécurité
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecurityPage()),
              );
            },
          ),
          Divider(),
          
          _buildSectionTitle('Préférences'),
          _buildListTile(
            context,
            icon: Icons.language,
            title: 'Langue',
            onTap: () {
              // Naviguer vers les paramètres de langue
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguageSettingsPage()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            onTap: () {
              // Ajouter la logique pour gérer l'appui sur la liste des notifications
            },
          ),
          Divider(),

          _buildSectionTitle('Autre'),
          _buildListTile(
            context,
            icon: Icons.help,
            title: 'Aide et support',
            onTap: () {
              // Naviguer vers la page d'aide
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.exit_to_app,
            title: 'Déconnexion',
            onTap: () {
              // Logique de déconnexion
              _logout();
            },
          ),
        ],
      ),
    );
  }

  // Fonction de déconnexion
  void _logout() {
    // Ici, tu peux implémenter la logique pour déconnecter l'utilisateur (comme supprimer un token, etc.)
    // Exemple : Navigator.pop(context); pour revenir à la page précédente
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Rediriger vers la page de connexion
    );
  }

  // Titre de section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  // Liste des options de paramètre avec un icône et un bouton
  Widget _buildListTile(BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required Function() onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.black),
      onTap: onTap,
    );
  }
}


class SecurityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sécurité')),
      body: Center(child: Text('Page de Sécurité')),
    );
  }
}

class LanguageSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Langue')),
      body: Center(child: Text('Page de Langue')),
    );
  }
}

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aide et support')),
      body: Center(child: Text('Page d\'Aide et Support')),
    );
  }
}

