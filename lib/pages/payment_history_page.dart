import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';

class PaymentHistoryPage extends StatefulWidget {
  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<Payment> _payments = [];
  Map<String, dynamic>? _proprietaire;
  double _totalPaid = 0.0;
  double _totalDue = 0.0;
  String? _startDate;
  String? _endDate;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    final userId = userProvider.user?.id;

    if (token != null && userId != null) {
      try {
        final result = await _paymentService.getPaymentHistory(userId, token);

        if (result['success']) {
          setState(() {
            _payments = result['payments'] as List<Payment>;
            _proprietaire = result['proprietaire'];
            _totalPaid = (result['totalPaid'] is int)
                ? (result['totalPaid'] as int).toDouble()
                : (result['totalPaid'] ?? 0.0).toDouble();
            _totalDue = (result['totalDue'] is int)
                ? (result['totalDue'] as int).toDouble()
                : (result['totalDue'] ?? 0.0).toDouble();
            _startDate = result['startDate'];
            _endDate = result['endDate'];
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Échec du chargement de l\'historique des paiements';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur est survenue: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Vous devez être connecté pour voir votre historique de paiements';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _openReceipt(String? pdfUrl) {
    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aucun reçu disponible pour ce paiement'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final url = 'http://localhost:3000$pdfUrl';

    // Show a message with the URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL du reçu: $url'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
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
          "Historique des paiements",
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
                          onPressed: _loadPaymentHistory,
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
                            if (_proprietaire != null)
                              Text(
                                "Propriétaire: ${_proprietaire!['firstName']} ${_proprietaire!['lastName']}",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total payé:",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  Payment.formatCurrency(_totalPaid),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total dû:",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  Payment.formatCurrency(_totalDue),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            if (_startDate != null && _endDate != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Période: ${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
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
                              onRefresh: _loadPaymentHistory,
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
                                                  payment.charge != null
                                                      ? payment.charge!['titre'] ?? 'Paiement'
                                                      : 'Paiement',
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
                                              if (isConfirmed && payment.receiptPdfPath != null)
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    ElevatedButton.icon(
                                                      onPressed: () => _openReceipt(payment.receiptPdfPath),
                                                      icon: Icon(Icons.receipt),
                                                      label: Text('Voir le reçu'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.green,
                                                        foregroundColor: Colors.white,
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
    );
  }
}
