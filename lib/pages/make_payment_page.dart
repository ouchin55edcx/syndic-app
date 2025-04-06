import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/payment_service.dart';
import '../models/charge_model.dart';

class MakePaymentPage extends StatefulWidget {
  final Charge charge;

  MakePaymentPage({required this.charge});

  @override
  _MakePaymentPageState createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();

  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedMethode;
  bool _isPartialPayment = false;

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  final List<String> _methodesPayment = [
    'carte bancaire',
    'virement bancaire',
    'espèces',
    'chèque',
    'autre'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize montant with the full amount
    _montantController.text = widget.charge.montantRestant.toString();
  }

  @override
  void dispose() {
    _montantController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _makePayment() async {
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

        final paymentData = {
          'chargeId': widget.charge.id,
          'montant': montant,
          'methodePaiement': _selectedMethode,
          'reference': _referenceController.text.trim(),
          'notes': _notesController.text.trim(),
        };

        final result = await _paymentService.makePayment(
          paymentData,
          token,
        );

        if (result['success']) {
          setState(() {
            _successMessage = result['message'] ?? 'Paiement enregistré avec succès';

            // Clear form
            _montantController.clear();
            _referenceController.clear();
            _notesController.clear();
            _selectedMethode = null;
            _isPartialPayment = false;
          });

          // Wait a moment to show success message before returning
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context, true); // Return true to indicate success
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Échec de l\'enregistrement du paiement';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur est survenue: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Vous devez être connecté pour effectuer un paiement';
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
          "Paiement de charge",
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
                // Charge info card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.charge.titre,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.charge.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.euro, size: 16, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Montant total: ${Charge.formatCurrency(widget.charge.montant)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet, size: 16, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Restant à payer: ${Charge.formatCurrency(widget.charge.montantRestant)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Échéance: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.charge.dateEcheance))}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

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
                  "Informations de paiement",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // Partial payment checkbox
                CheckboxListTile(
                  title: Text("Paiement partiel"),
                  value: _isPartialPayment,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPartialPayment = value ?? false;
                      if (!_isPartialPayment) {
                        _montantController.text = widget.charge.montantRestant.toString();
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 15),

                TextFormField(
                  controller: _montantController,
                  decoration: InputDecoration(
                    labelText: "Montant (€)",
                    prefixIcon: Icon(Icons.euro),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  enabled: _isPartialPayment, // Only enable if partial payment
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un montant';
                    }
                    try {
                      double amount = double.parse(value.replaceAll(',', '.'));
                      if (amount <= 0) {
                        return 'Le montant doit être supérieur à 0';
                      }
                      if (amount > widget.charge.montantRestant) {
                        return 'Le montant ne peut pas dépasser le montant restant à payer';
                      }
                    } catch (e) {
                      return 'Veuillez entrer un montant valide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: _selectedMethode,
                  decoration: InputDecoration(
                    labelText: "Méthode de paiement",
                    prefixIcon: Icon(Icons.payment),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _methodesPayment.map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method.substring(0, 1).toUpperCase() + method.substring(1)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMethode = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une méthode de paiement';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                TextFormField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    labelText: "Référence",
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Ex: CB-123456, VIR-789012",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une référence';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: "Notes",
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Informations complémentaires",
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 30),

                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _makePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
                            "Confirmer le paiement",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
