import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';
import '../services/proprietaire_service.dart';
import '../models/proprietaire_profile_model.dart';
import 'edit_proprietaire_profile_page.dart';

class ProprietaireProfilePage extends StatefulWidget {
  @override
  _ProprietaireProfilePageState createState() => _ProprietaireProfilePageState();
}

class _ProprietaireProfilePageState extends State<ProprietaireProfilePage> {
  final ProprietaireService _proprietaireService = ProprietaireService();
  bool _isLoading = true;
  String _errorMessage = '';
  ProprietaireProfile? _profile;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
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
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 80,
                                  backgroundColor: const Color.fromARGB(255, 198, 198, 198),
                                  backgroundImage:
                                      _profileImage != null ? FileImage(_profileImage!) : null,
                                  child: _profileImage == null
                                      ? Icon(Icons.person, size: 80, color: Colors.white)
                                      : null,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showImageSourceDialog(context);
                                  },
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                                    child: Icon(Icons.camera_alt, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              _profile!.fullName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              _profile!.email,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 30),
                            _buildInfoCard(),
                            SizedBox(height: 20),
                            _buildApartmentCard(),
                            SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: _navigateToEditProfile,
                              icon: Icon(Icons.edit),
                              label: Text("Modifier le profil"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
            _buildInfoRow(Icons.calendar_today, "Date d'acquisition", 
                _profile!.ownershipDate != null 
                    ? _formatDate(_profile!.ownershipDate!) 
                    : "Non spécifiée"),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
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
