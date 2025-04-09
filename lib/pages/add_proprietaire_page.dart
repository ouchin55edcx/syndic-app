import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/appartement_model.dart';
import '../providers/user_provider.dart';
import '../services/proprietaire_service.dart';
import '../services/appartement_service.dart';

class AddProprietairePage extends StatefulWidget {
  @override
  _AddProprietairePageState createState() => _AddProprietairePageState();
}

class _AddProprietairePageState extends State<AddProprietairePage> {
  final _formKey = GlobalKey<FormState>();
  final ProprietaireService _proprietaireService = ProprietaireService();
  final AppartementService _appartementService = AppartementService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _ownershipDateController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Appartement> _appartements = [];
  Appartement? _selectedAppartement;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAppartements();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _ownershipDateController.dispose();
    super.dispose();
  }

  Future<void> _loadAppartements() async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    debugPrint('Loading appartements with token: $token');

    if (token != null) {
      final result = await _appartementService.getAllAppartements(token);

      if (result['success']) {
        final allApartments = result['appartements'] as List<dynamic>;
        
        // Convert to Appartement objects without filtering
        List<Appartement> apartments = allApartments.map((apt) {
          if (apt is Appartement) return apt;
          return Appartement.fromJson(apt as Map<String, dynamic>);
        }).toList();

        setState(() {
          _appartements = apartments;
          if (_appartements.isNotEmpty) {
            _selectedAppartement = _appartements.first;
          }
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load appartements';
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _ownershipDateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      debugPrint('Submitting form with token: $token');

      if (token != null && _selectedAppartement != null) {
        final proprietaireData = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'appartementId': _selectedAppartement!.id,
          'ownershipDate': _selectedDate.toIso8601String(),
        };

        debugPrint('Sending proprietaire data: $proprietaireData');

        final result = await _proprietaireService.createProprietaire(
          proprietaireData,
          token,
        );

        if (result['success']) {
          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          setState(() {
            _errorMessage = result['message'];
          });
        }
      } else {
        setState(() {
          _errorMessage = 'You must be logged in as a syndic to add proprietaires';
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Proprietaire'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _appartements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // First Name field
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Last Name field
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Number field
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Appartement dropdown
                    DropdownButtonFormField<Appartement>(
                      decoration: const InputDecoration(
                        labelText: 'Appartement',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedAppartement,
                      items: _appartements.map((appartement) {
                        return DropdownMenuItem<Appartement>(
                          value: appartement,
                          child: Text('Appartement ${appartement.numero}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAppartement = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an appartement';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ownership Date field
                    TextFormField(
                      controller: _ownershipDateController,
                      decoration: InputDecoration(
                        labelText: 'Ownership Date',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an ownership date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Create Proprietaire'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
