import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'proprietaire_profile_page.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';
  String _loginType = AuthService.SYNDIC; // Default to syndic login

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Toggle between syndic and proprietaire login
  void _toggleLoginType() {
    setState(() {
      _loginType = _loginType == AuthService.SYNDIC
          ? AuthService.PROPRIETAIRE
          : AuthService.SYNDIC;
      _errorMessage = '';
    });
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _authService.login(
        _loginType,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result['success']) {
        // Login successful
        final token = result['token'];
        debugPrint('Login successful with token: $token');

        Provider.of<UserProvider>(context, listen: false).setUser(
          result['user'],
          token,
          result['userType'],
        );

        // Navigate based on user type
        if (result['userType'] == AuthService.PROPRIETAIRE) {
          // Proprietaire goes to profile page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProprietaireProfilePage()),
          );
        } else {
          // Syndic goes to home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        // Login failed
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset("assets/backgroundlogin.jpg", fit: BoxFit.cover),
          ),
          // Logo en haut
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                "assets/logo.jpeg",
                height: 150, // Augmentation de la taille du logo
              ),
            ),
          ),
          // Formulaire de connexion
          Positioned(
            top: 320,
            left: 30,
            right: 30,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  // Login type selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Syndic'),
                        selected: _loginType == AuthService.SYNDIC,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _loginType = AuthService.SYNDIC;
                              _errorMessage = '';
                            });
                          }
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.black.withOpacity(0.8),
                        labelStyle: TextStyle(
                          color: _loginType == AuthService.SYNDIC ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 20),
                      ChoiceChip(
                        label: const Text('Propriétaire'),
                        selected: _loginType == AuthService.PROPRIETAIRE,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _loginType = AuthService.PROPRIETAIRE;
                              _errorMessage = '';
                            });
                          }
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.black.withOpacity(0.8),
                        labelStyle: TextStyle(
                          color: _loginType == AuthService.PROPRIETAIRE ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Champ email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Champ mot de passe
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: "Mot de passe",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  // Error message
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 30),
                  // Bouton de connexion avec une largeur réduite
                  SizedBox(
                    width: 220, // Largeur ajustée pour le texte plus long
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12), // Hauteur inchangée
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _loginType == AuthService.SYNDIC
                                ? "Se connecter comme Syndic"
                                : "Se connecter comme Propriétaire",
                              style: const TextStyle(fontSize: 15, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Lien "Mot de passe oublié ?"
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vérifiez votre Gmail"),
                          ),
                        );
                      },
                      child: const Text(
                        "Mot de passe oublié ?",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
