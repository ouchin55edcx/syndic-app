import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'meeting_provider.dart';
import '../widgets/NotificationBell.dart'; 
import 'notifications_page.dart';
import '../widgets/user_avatar.dart';
import 'UserProfilePage.dart';
import 'MeetingListPage.dart';

class ScheduleMeetingPage extends StatelessWidget {
  const ScheduleMeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Planifier une réunion",
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMeetingCard(
              context,
              title: "Date de la réunion",
              icon: Icons.calendar_today,
              child: Consumer<MeetingProvider>(
                builder: (context, provider, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.selectedDate == null
                          ? "Aucune date sélectionnée"
                          : DateFormat('yyyy-MM-dd').format(provider.selectedDate!),
                      style: TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: Icon(Icons.date_range, color: const Color.fromARGB(255, 75, 160, 173)),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          provider.setDate(pickedDate);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildMeetingCard(
              context,
              title: "Heure de la réunion",
              icon: Icons.access_time,
              child: Consumer<MeetingProvider>(
                builder: (context, provider, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.selectedTime == null
                          ? "Aucune heure sélectionnée"
                          : provider.selectedTime!.format(context),
                      style: TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: Icon(Icons.access_time, color: const Color.fromARGB(255, 75, 160, 173)),
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          provider.setTime(pickedTime);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildMeetingCard(
              context,
              title: "Lieu de la réunion",
              icon: Icons.location_on,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Saisir le lieu...",
                  border: InputBorder.none,
                ),
                onChanged: (text) => context.read<MeetingProvider>().setLocation(text),
                controller: context.read<MeetingProvider>().locationController,
              ),
            ),
            _buildMeetingCard(
              context,
              title: "Ordre du jour",
              icon: Icons.edit,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Saisir l'ordre du jour...",
                  border: InputBorder.none,
                ),
                maxLines: 3,
                onChanged: (text) => context.read<MeetingProvider>().setAgenda(text),
                controller: context.read<MeetingProvider>().agendaController,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final provider = context.read<MeetingProvider>();
                      provider.saveMeeting(context);
                      provider.clearFields();
                  ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Réunion programmée avec succès"),
                          backgroundColor: const Color.fromARGB(255, 2, 180, 8),
                        ),
                      );
                    },
                    child: Text(
                      "Enregistrer",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MeetingListPage()),
                      );
                    },
                    child: Text(
                      "Voir la liste",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color.fromARGB(255, 75, 160, 173)),
                SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}