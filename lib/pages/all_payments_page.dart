import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';
import 'pending_payments_page.dart';

class AllPaymentsPage extends StatefulWidget {
  @override
  _AllPaymentsPageState createState() => _AllPaymentsPageState();
}

class _AllPaymentsPageState extends State<AllPaymentsPage> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<Payment> _payments = [];
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final result = await _paymentService.getAllPayments(token);

        if (result['success']) {
          final List<Payment> payments = result['payments'] as List<Payment>;

          // Calculate total amount
          double total = 0.0;
          for (var payment in payments) {
            total += payment.montant;
          }

          setState(() {
            _payments = payments;
            _totalAmount = total;
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Échec du chargement des paiements';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur est survenue: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Vous devez être connecté en tant que syndic pour voir les paiements';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToPendingPayments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PendingPaymentsPage(),
      ),
    ).then((_) => _loadPayments()); // Reload payments when returning
  }

  Future<void> _confirmPayment(Payment payment) async {
    // Show confirmation dialog
    bool confirm = await showDialog(
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Confirmer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirm) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        // Prepare confirmation data
        final confirmationData = {
          'notes': 'Paiement vérifié et confirmé par le syndic',
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
          _loadPayments();
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
          "Tous les paiements",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Button to navigate to pending payments
          ElevatedButton.icon(
            icon: Icon(Icons.pending_actions, color: Colors.white),
            label: Text('Paiements en attente', style: TextStyle(color: Colors.white)),
            onPressed: _navigateToPendingPayments,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          SizedBox(width: 8),
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
                          onPressed: _loadPayments,
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Summary card
                    Card(
                      margin: EdgeInsets.all(16),
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
                              "Résumé des paiements",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Nombre de paiements:",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "${_payments.length}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Montant total:",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  Payment.formatCurrency(_totalAmount),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Payments list
                    Expanded(
                      child: _payments.isEmpty
                          ? Center(
                              child: Text(
                                'Aucun paiement à afficher',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadPayments,
                              child: ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: _payments.length,
                                itemBuilder: (context, index) {
                                  final payment = _payments[index];
                                  final bool isConfirmed = payment.statut.toLowerCase() == 'confirmé';
                                  final bool isPending = payment.statut.toLowerCase() == 'en attente';

                                  return Card(
                                    margin: EdgeInsets.only(bottom: 16),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Color(int.parse(Payment.getStatusColor(payment.statut).substring(1, 7), radix: 16) + 0xFF000000).withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Color(int.parse(Payment.getStatusColor(payment.statut).substring(1, 7), radix: 16) + 0xFF000000).withOpacity(0.1),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isConfirmed ? Icons.check_circle : (isPending ? Icons.timelapse : Icons.warning),
                                                color: Color(int.parse(Payment.getStatusColor(payment.statut).substring(1, 7), radix: 16) + 0xFF000000),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "Paiement #${payment.id.substring(0, 8)}...",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Color(int.parse(Payment.getStatusColor(payment.statut).substring(1, 7), radix: 16) + 0xFF000000),
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
                                                    'Propriétaire: ${payment.proprietaireId}',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.receipt, size: 16, color: Colors.blue),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Charge: ${payment.chargeId}',
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
                                                // Add confirm button for pending payments
                                                if (isPending)
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
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToPendingPayments,
        backgroundColor: Colors.orange,
        child: Icon(Icons.pending_actions, color: Colors.white),
        tooltip: 'Paiements en attente',
      ),
    );
  }
}
