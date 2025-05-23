import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/user_provider.dart';
import '../services/proprietaire_service.dart';
import '../models/proprietaire_profile_model.dart';
import 'edit_proprietaire_profile_page.dart';
import 'notifications_page.dart';
import '../widgets/NotificationBell.dart';
import 'charges_list_page.dart';
import 'payment_history_page.dart';
import 'home_screen.dart';
import 'LoginPage.dart';

class ProprietaireProfilePage extends StatefulWidget {
  @override
  _ProprietaireProfilePageState createState() => _ProprietaireProfilePageState();
}

class _ProprietaireProfilePageState extends State<ProprietaireProfilePage> {
  final ProprietaireService _proprietaireService = ProprietaireService();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isLoading = true;
  String _errorMessage = '';
  ProprietaireProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final result = await _proprietaireService.getProprietaireProfile(token);

        if (result['success']) {
          setState(() {
            _profile = result['proprietaire'];
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to load profile';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred while loading profile: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'You must be logged in to view your profile';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToEditProfile() async {
    if (_profile == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProprietaireProfilePage(profile: _profile!),
      ),
    );

    if (result == true) {
      _loadProfile(); // Reload profile after update
    }
  }

  void _logout() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Déconnexion'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Clear user data from provider
                Provider.of<UserProvider>(context, listen: false).clearUser();

                // Navigate to login page
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false, // Remove all previous routes
                );
              },
              child: Text('Déconnexion', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil Propriétaire",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Notification bell icon
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NotificationsPage()),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: NotificationBell(),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProfile,
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : _profile == null
                  ? Center(child: Text('Aucune information de profil disponible'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            _buildInfoCard(),
                            SizedBox(height: 20),
                            _buildApartmentCard(),
                            SizedBox(height: 30),
                            Container(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _navigateToEditProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Modifier le profil',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _logout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Déconnexion',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Profile page is selected
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        selectedItemColor: const Color.fromARGB(255, 75, 160, 173),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Important for more than 3 items
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Paiements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0: // Profile - already here
              break;
            case 1: // Payments
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentHistoryPage()),
              );
              break;
            case 2: // Notifications
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informations personnelles",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(height: 30),
            _buildInfoRow(Icons.phone, "Téléphone", _profile!.phoneNumber),
            SizedBox(height: 15),
            _buildInfoRow(Icons.email, "Email", _profile!.email),
            SizedBox(height: 15),
            _buildInfoRow(
              Icons.calendar_today, 
              "Date d'acquisition",
              _profile!.ownershipDate != null
                  ? _formatDate(_profile!.ownershipDate!)
                  : "Non spécifiée"
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApartmentCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informations sur l'appartement",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(height: 30),
            if (_profile!.appartement != null) ...[
              _buildInfoRow(Icons.apartment, "Numéro", _profile!.appartement!.numero),
              SizedBox(height: 15),
              _buildInfoRow(Icons.stairs, "Étage", _profile!.appartement!.etage.toString()),
              SizedBox(height: 15),
              _buildInfoRow(Icons.square_foot, "Superficie", "${_profile!.appartement!.superficie} m²"),
              SizedBox(height: 15),
              _buildInfoRow(Icons.meeting_room, "Nombre de pièces", _profile!.appartement!.nombrePieces.toString()),
              SizedBox(height: 15),
              _buildInfoRow(Icons.info_outline, "Statut", _profile!.appartement!.statut),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Aucun appartement associé à ce profil",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 75, 160, 173), size: 22),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialManagementCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gestion financière",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFinancialButton(
                  "Historique des paiements",
                  Icons.receipt,
                  Colors.blue,
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentHistoryPage()),
                  ),
                ),
                _buildFinancialButton(
                  "Notifications",
                  Icons.notifications,
                  Colors.orange,
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsPage()),
                  ),
                ),
                _buildFinancialButton(
                  "Accueil",
                  Icons.home,
                  Colors.green,
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 90,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Date invalide';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: const Color.fromARGB(255, 145, 147, 150)),
              title: Text("Choisir depuis la galerie"),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: const Color.fromARGB(255, 145, 147, 150)),
              title: Text("Prendre une photo"),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
