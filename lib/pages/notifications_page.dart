import 'package:flutter/material.dart';
class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final TextEditingController _notificationController = TextEditingController();
  List<Map<String, dynamic>> _notifications = [
    {"text": "Réunion des copropriétaires samedi à 18h.", "timestamp": DateTime.now(), "status": "sent"},
    {"text": "Travaux d'entretien prévus lundi prochain.", "timestamp": DateTime.now(), "status": "sent"},
  ]; // Liste des notifications (simulées)

  bool _isTyping = false; // Indicateur de saisie

  // Fonction pour envoyer une notification
  void sendNotification(String message) {
    if (message.isNotEmpty) {
      setState(() {
        _notifications.insert(0, {
          "text": "📢 $message",
          "timestamp": DateTime.now(),
          "status": "sent"
        });
        _isTyping = false; // Arrêter le statut de "tapé..."
      });
      _notificationController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Fond comme WhatsApp
       appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100]?.withOpacity(0.7), // Ajouter transparence
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _notifications[index]['text'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${_notifications[index]['timestamp'].hour}:${_notifications[index]['timestamp'].minute}",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (_notifications[index]["status"] == "sent") ...[
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.check, color: const Color.fromARGB(255, 75, 160, 173), size: 16),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping) ...[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text("L'utilisateur est en train de taper...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            ),
          ],
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8), // Fond transparent
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _notificationController,
                    onChanged: (text) {
                      setState(() {
                        _isTyping = text.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Écrire une notification...",
                      filled: true,
                      fillColor: Colors.grey[100]?.withOpacity(0.6), // Transparent
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () => sendNotification(_notificationController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


