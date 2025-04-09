import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/charge_service.dart';
import '../services/appartement_service.dart';
import '../models/appartement_model.dart';

class CreateChargePage extends StatefulWidget {
  @override
  _CreateChargePageState createState() => _CreateChargePageState();
}

class _CreateChargePageState extends State<CreateChargePage> {
  final _formKey = GlobalKey<FormState>();
  final ChargeService _chargeService = ChargeService();
  final AppartementService _appartementService = AppartementService();

  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _dateEcheanceController = TextEditingController();

  String? _selectedAppartementId;
  String? _selectedCategorie;
  DateTime? _selectedDate;

  bool _isLoading = false;
  bool _isLoadingAppartements = true;
  String _errorMessage = '';
  String _successMessage = '';
  List<dynamic> _appartements = [];

  final List<String> _categories = [
    'maintenance',
    'réparation',
    'général',
    'eau',
    'électricité',
    'chauffage',
    'assurance',
    'autre'
  ];

  @override
  void initState() {
    super.initState();
    _loadAppartements();
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _montantController.dispose();
    _dateEcheanceController.dispose();
    super.dispose();
  }

  Future<void> _loadAppartements() async {
    setState(() {
      _isLoadingAppartements = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final result = await _appartementService.getAllAppartements(token);

        if (result['success']) {
          setState(() {
            _appartements = result['appartements'] ?? [];
            // Debug the type of appartements
            if (_appartements.isNotEmpty) {
              debugPrint('Appartement type: ${_appartements.first.runtimeType}');
            }
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Échec du chargement des appartements';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur est survenue: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Vous devez être connecté en tant que syndic pour créer une charge';
      });
    }

    setState(() {
      _isLoadingAppartements = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateEcheanceController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _createCharge() async {
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
      try {
        // Parse montant to double
        double montant = double.tryParse(_montantController.text.replaceAll(',', '.')) ?? 0.0;

        final chargeData = {
          'titre': _titreController.text.trim(),
          'description': _descriptionController.text.trim(),
          'montant': montant,
          'dateEcheance': _dateEcheanceController.text.trim(),
          'appartementId': _selectedAppartementId,
          'categorie': _selectedCategorie,
        };

        final result = await _chargeService.createCharge(
          chargeData,
          token,
        );

        if (result['success']) {
          setState(() {
            _successMessage = result['message'] ?? 'Charge créée avec succès';

            // Clear form
            _titreController.clear();
            _descriptionController.clear();
            _montantController.clear();
            _dateEcheanceController.clear();
            _selectedAppartementId = null;
            _selectedCategorie = null;
            _selectedDate = null;
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Échec de la création de la charge';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur est survenue: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Vous devez être connecté en tant que syndic pour créer une charge';
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
        title: Text(
          "Créer une charge",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                if (_successMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _successMessage,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),

                Text(
                  "Informations de la charge",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _titreController,
                  decoration: InputDecoration(
                    labelText: "Titre",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                TextFormField(
                  controller: _montantController,
                  decoration: InputDecoration(
                    labelText: "Montant (DH)",
                    prefixIcon: Icon(Icons.payments),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un montant';
                    }
                    try {
                      double.parse(value.replaceAll(',', '.'));
                    } catch (e) {
                      return 'Veuillez entrer un montant valide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                TextFormField(
                  controller: _dateEcheanceController,
                  decoration: InputDecoration(
                    labelText: "Date d'échéance",
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_month),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une date d\'échéance';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: _selectedCategorie,
                  decoration: InputDecoration(
                    labelText: "Catégorie",
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category.substring(0, 1).toUpperCase() + category.substring(1)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategorie = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une catégorie';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                _isLoadingAppartements
                    ? Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        value: _selectedAppartementId,
                        decoration: InputDecoration(
                          labelText: "Appartement",
                          prefixIcon: Icon(Icons.apartment),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: _appartements.map<DropdownMenuItem<String>>((appartement) {
                          if (appartement is Appartement) {
                            return DropdownMenuItem<String>(
                              value: appartement.id,
                              child: Text('Appartement ${appartement.numero}'),
                            );
                          } else {
                            // Fallback for Map or other types
                            final dynamic apt = appartement;
                            final String id = apt is Map ? apt['id'] ?? '' : '';
                            final String numero = apt is Map ? apt['numero'] ?? '' : 'Unknown';
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text('Appartement $numero'),
                            );
                          }
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedAppartementId = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un appartement';
                          }
                          return null;
                        },
                      ),
                SizedBox(height: 30),

                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createCharge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Créer la charge",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
