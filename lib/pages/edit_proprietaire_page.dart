import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/proprietaire_service.dart';

class EditProprietairePage extends StatefulWidget {
  final Map<String, dynamic> proprietaire;

  EditProprietairePage({required this.proprietaire});

  @override
  _EditProprietairePageState createState() => _EditProprietairePageState();
}

class _EditProprietairePageState extends State<EditProprietairePage> {
  final _formKey = GlobalKey<FormState>();
  final ProprietaireService _proprietaireService = ProprietaireService();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _apartmentNumberController;
  // Suppression de _buildingIdController

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.proprietaire['firstName']);
    _lastNameController = TextEditingController(text: widget.proprietaire['lastName']);
    _phoneNumberController = TextEditingController(text: widget.proprietaire['phoneNumber']);
    _apartmentNumberController = TextEditingController(text: widget.proprietaire['apartmentNumber']);
    // Suppression de _buildingIdController
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _apartmentNumberController.dispose();
    // Suppression de _buildingIdController
    super.dispose();
  }

  Future<void> _updateProprietaire() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      final proprietaireData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
        'apartmentNumber': _apartmentNumberController.text.trim(),
        // Suppression de buildingId dans les données envoyées
      };

      try {
        final result = await _proprietaireService.updateProprietaire(
          widget.proprietaire['id'],
          proprietaireData,
          token,
        );

        if (result['success']) {
          setState(() {
            _successMessage = result['message'];
          });
          
          // Wait a moment to show success message before returning
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context, true); // Return true to indicate success
          });
        } else {
          setState(() {
            _errorMessage = result['message'];
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur est survenue: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Vous devez être connecté pour mettre à jour un propriétaire';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le propriétaire'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              if (_successMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _successMessage,
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prénom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Numéro de téléphone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro de téléphone';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _apartmentNumberController,
                decoration: InputDecoration(labelText: 'Numéro d\'appartement'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro d\'appartement';
                  }
                  return null;
                },
              ),
              // Suppression du champ buildingId
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProprietaire,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Mettre à jour'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
