import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_profile_page.dart'; // Import de la nouvelle page

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? _profileImage;
  
  // Informations de l'utilisateur
  String userName = "Aicha";
  String userEmail = "syndic.aicha@gmail.com";
  String userPhone = "+212 6 81 22 64";
  String officeAddress = "Bureau 12, Avenue des Syndics, Paris";

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _navigateToEditProfile() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          name: userName,
          email: userEmail,
          phone: userPhone,
          address: officeAddress,
        ),
      ),
    );

    if (updatedData != null) {
      setState(() {
        userName = updatedData['name'];
        userEmail = updatedData['email'];
        userPhone = updatedData['phone'];
        officeAddress = updatedData['address'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(
    "Profil du Syndic",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
  ),
  centerTitle: true,
  backgroundColor: const Color.fromARGB(255, 64, 66, 69),
  iconTheme: IconThemeData(color: Colors.white), 
),
      body: Padding(
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
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileInfo(Icons.person, "Nom", userName),
                    _buildProfileInfo(Icons.email, "Email", userEmail),
                    _buildProfileInfo(Icons.phone, "Téléphone", userPhone),
                    Divider(),
                    _buildProfileInfo(Icons.business, "Bureau", officeAddress),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _navigateToEditProfile,
              icon: Icon(Icons.edit, color: const Color.fromARGB(255, 255, 255, 255)),
              label: Text("Modifier le Profil"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color:const Color.fromARGB(255, 75, 160, 173), size: 26),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "$title : $value",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
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
