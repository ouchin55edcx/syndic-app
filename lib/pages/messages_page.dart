import 'package:flutter/material.dart';
import '../widgets/user_avatar.dart'; // Import du UserAvatar
import 'UserProfilePage.dart'; // Import de la page de profil utilisateur
import '../widgets/NotificationBell.dart'; 
import 'notifications_page.dart';
class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final List<Map<String, String>> owners = [
    {"name": "M. Dupont", "id": "1"},
    {"name": "Mme Lefevre", "id": "2"},
    {"name": "M. Bernard", "id": "3"},
    {"name": "Mme Martin", "id": "4"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Messages",
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
      body: ListView.builder(
        itemCount: owners.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                owners[index]['name']!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Tapez pour discuter", style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(owners[index]['name']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String ownerName;

  ChatPage(this.ownerName);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({
          "text": "Syndic: $message",
          "timestamp": DateTime.now(),
          "status": "sent"
        });
        _isTyping = false;
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 75, 160, 173),
        title: Text(widget.ownerName, style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isSyndic = _messages[index]["text"].startsWith("Syndic:");
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Align(
                    alignment: isSyndic ? Alignment.centerRight : Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSyndic ? Colors.green[100]?.withOpacity(0.8) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _messages[index]["text"].replaceFirst("Syndic: ", ""),
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${_messages[index]["timestamp"].hour}:${_messages[index]["timestamp"].minute}",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (_messages[index]["status"] == "sent") ...[
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
            padding: EdgeInsets.all(8),
            color: Colors.white.withOpacity(0.8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (text) {
                      setState(() {
                        _isTyping = text.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      filled: true,
                      fillColor: Colors.grey[100]?.withOpacity(0.6),
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
                    onPressed: () => sendMessage(_messageController.text),
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
