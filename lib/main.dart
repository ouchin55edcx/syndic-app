import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'pages/LoginPage.dart'; // Fichier de login
import 'pages/meeting_provider.dart';
import 'pages/schedule_meeting_page.dart';
import 'providers/user_provider.dart';

void main() {

  runApp(GestionSyndicApp());
}

class GestionSyndicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MeetingProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: LoginPage(), // Démarre avec la page de connexion
      ),
    );
  }
}
