import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'meeting_provider.dart';
import 'EditMeetingPage.dart'; // Import de la nouvelle page

class MeetingListPage extends StatelessWidget {
  const MeetingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Modifier le Profil",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Consumer<MeetingProvider>(
        builder: (context, provider, child) {
          if (provider.meetings.isEmpty) {
            return const Center(child: Text("Aucune réunion enregistrée."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.meetings.length,
            itemBuilder: (context, index) {
              final meeting = provider.meetings[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(meeting.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Heure: ${meeting.time}"),
                      Text("Lieu: ${meeting.location}"),
                      Text("Ordre du jour: ${meeting.agenda}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMeetingPage(index: index),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          provider.deleteMeeting(index);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}