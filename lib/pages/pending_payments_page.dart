import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';

class PendingPaymentsPage extends StatefulWidget {
  @override
  _PendingPaymentsPageState createState() => _PendingPaymentsPageState();
}

class _PendingPaymentsPageState extends State<PendingPaymentsPage> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<Payment> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadPendingPayments();
  }

  Future<void> _loadPendingPayments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final result = await _paymentService.getPendingPayments(token);

        if (result['success']) {
          setState(() {
            _payments = result['payments'] as List<Payment>;
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Échec du chargement des paiements en attente';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur est survenue: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Vous devez être connecté en tant que syndic pour voir les paiements en attente';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _confirmPayment(Payment payment) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer le paiement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Voulez-vous confirmer ce paiement?'),
              SizedBox(height: 16),
              Text('Montant: ${Payment.formatCurrency(payment.montant)}', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Méthode: ${payment.methodePaiement}'),
              Text('Référence: ${payment.reference}'),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Notes (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => _confirmationNotes = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _processPaymentConfirmation(payment);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Confirmer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _confirmationNotes = 'Paiement vérifié et confirmé par le syndic';

  Future<void> _processPaymentConfirmation(Payment payment) async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        // Prepare confirmation data
        final confirmationData = {
          'notes': _confirmationNotes,
        };

        debugPrint('Confirming payment ${payment.id} with token: $token');

        // Call the API to confirm the payment
        final result = await _paymentService.confirmPayment(
          payment.id,
          confirmationData,
          token,
        );

        if (result['success']) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Paiement confirmé avec succès'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Display payment details if available
          if (result['payment'] != null) {
            final confirmedPayment = result['payment'] as Payment;
            debugPrint('Payment confirmed: ${confirmedPayment.id}');
            debugPrint('New status: ${confirmedPayment.statut}');
          }

          // Reload the payments list
          _loadPendingPayments();
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Échec de la confirmation du paiement'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        // Show exception message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _rejectPayment(Payment payment) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rejeter le paiement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Voulez-vous rejeter ce paiement?'),
              SizedBox(height: 16),
              Text('Montant: ${Payment.formatCurrency(payment.montant)}', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Méthode: ${payment.methodePaiement}'),
              Text('Référence: ${payment.reference}'),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Motif du rejet (obligatoire)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => _rejectionNotes = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_rejectionNotes.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Veuillez indiquer un motif de rejet'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop();
                await _processPaymentRejection(payment);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Rejeter', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _rejectionNotes = 'Paiement rejeté par le syndic';

  Future<void> _processPaymentRejection(Payment payment) async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final rejectionData = {
          'notes': _rejectionNotes,
        };

        final result = await _paymentService.rejectPayment(
          payment.id,
          rejectionData,
          token,
        );

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Paiement rejeté avec succès'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          _loadPendingPayments(); // Reload the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Échec du rejet du paiement'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Paiements en attente",
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
                          onPressed: _loadPendingPayments,
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : _payments.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun paiement en attente',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPendingPayments,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _payments.length,
                        itemBuilder: (context, index) {
                          final payment = _payments[index];

                          return Card(
                            margin: EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.orange.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.timelapse,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          payment.charge != null
                                              ? payment.charge!['titre'] ?? 'Paiement en attente'
                                              : 'Paiement en attente',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          payment.statut,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person, size: 16, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text(
                                            'Propriétaire ID: ${payment.proprietaireId}',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.euro, size: 16, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text(
                                            'Montant: ${Payment.formatCurrency(payment.montant)}',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text(
                                            'Date: ${_formatDateTime(payment.datePayment)}',
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.payment, size: 16, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text(
                                            'Méthode: ${payment.methodePaiement}',
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.numbers, size: 16, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text(
                                            'Référence: ${payment.reference}',
                                          ),
                                        ],
                                      ),
                                      if (payment.notes.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.note, size: 16, color: Colors.blue),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  'Notes: ${payment.notes}',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (payment.isPartial)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.account_balance_wallet, size: 16, color: Colors.orange),
                                              SizedBox(width: 4),
                                              Text(
                                                'Paiement partiel - Restant: ${Payment.formatCurrency(payment.remainingAmount)}',
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () => _confirmPayment(payment),
                                            icon: Icon(Icons.check_circle),
                                            label: Text('Confirmer'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          ElevatedButton.icon(
                                            onPressed: () => _rejectPayment(payment),
                                            icon: Icon(Icons.cancel),
                                            label: Text('Rejeter'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
