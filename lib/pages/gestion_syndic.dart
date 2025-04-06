import 'package:flutter/material.dart';
import 'versement.dart';
import 'notifications_page.dart';
import '../widgets/NotificationBell.dart';
import '../widgets/user_avatar.dart';
import 'UserProfilePage.dart';
import '../widgets/plus.dart';
import 'OwnerFormPage.dart';

class GestionSyndicScreen extends StatefulWidget {
  @override
  _GestionSyndicScreenState createState() => _GestionSyndicScreenState();
}

class _GestionSyndicScreenState extends State<GestionSyndicScreen> {
  String? selectedImmeuble = '8';
  String? selectedAppartement = '8';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Propriétaires",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Spacer(), // Ajoute un espace flexible entre le titre et les icônes
            SizedBox(width: 20), // Ajoute un petit espace entre les icônes
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsPage(),
                  ), // Redirige vers NotificationsPage
                );
              },
              child:
                  NotificationBell(), // Icône de notification avec 3 notifications
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedImmeuble,
                    items:
                        ["8", "9", "10"]
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text("Immeuble $e"),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => selectedImmeuble = val),
                    decoration: InputDecoration(
                      labelText: "Num_IMM",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedAppartement,
                    items:
                        ["8", "9", "10"]
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text("Appt $e"),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (val) => setState(() => selectedAppartement = val),
                    decoration: InputDecoration(
                      labelText: "Num_Appt",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: buildButton("Chercher", () {})),
                SizedBox(width: 10),
                Expanded(child: buildButton("Générer un avis client", () {})),
                SizedBox(width: 10),
                Expanded(
                  child: buildButton("Versement", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VersementScreen(),
                      ),
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildTextField("État"),
                    buildTextField("Copropriétaire"),
                    buildTextField("Téléphone"),
                    buildTextField("Email"),
                    buildTextField("Mnt impayé"),
                    buildTextField("Mnt réglé"),
                    buildTextField("Date signature contrat"),
                    buildTextField("Mnt à payer"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildTextField(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.blue.shade50,
        ),
      ),
    );
  }
}
