import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/charge_service.dart';
import '../models/charge_model.dart';
import 'make_payment_page.dart';
import 'create_charge_page.dart';
import 'payment_history_page.dart';
import 'proprietaire_profile_page.dart';
import 'notifications_page.dart';

class ChargesListPage extends StatefulWidget {
  @override
  _ChargesListPageState createState() => _ChargesListPageState();
}

class _ChargesListPageState extends State<ChargesListPage> {
  final ChargeService _chargeService = ChargeService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<Charge> _charges = [];
  String _proprietaireName = '';
  double _totalCharges = 0.0;
  double _totalPaid = 0.0;
  double _totalRemaining = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCharges();
  }

  Future<void> _loadCharges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    final userId = userProvider.user?.id;
    final isSyndic = userProvider.isSyndic;

    if (token != null) {
      try {
        Map<String, dynamic> result;

        if (isSyndic) {
          // If user is syndic, get all charges
          result = await _chargeService.getAllCharges(token);
        } else if (userId != null) {
          // If user is proprietaire, get only their charges
          result = await _chargeService.getChargesForProprietaire(userId, token);
        } else {
          setState(() {
            _errorMessage = 'Impossible d\'identifier l\'utilisateur';
          });
          return;
        }

        if (result['success']) {
          setState(() {
            _charges = result['charges'] as List<Charge>;
            _proprietaireName = result['proprietaireName'] ?? '';
            _totalCharges = (result['totalCharges'] is int)
                ? (result['totalCharges'] as int).toDouble()
                : (result['totalCharges'] ?? 0.0).toDouble();
            _totalPaid = (result['totalPaid'] is int)
                ? (result['totalPaid'] as int).toDouble()
                : (result['totalPaid'] ?? 0.0).toDouble();
            _totalRemaining = (result['totalRemaining'] is int)
                ? (result['totalRemaining'] as int).toDouble()
                : (result['totalRemaining'] ?? 0.0).toDouble();
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Échec du chargement des charges';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur est survenue: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Vous devez être connecté pour voir les charges';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToMakePayment(Charge charge) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MakePaymentPage(charge: charge),
      ),
    ).then((_) => _loadCharges()); // Reload charges when returning
  }

  void _navigateToCreateCharge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateChargePage(),
      ),
    ).then((_) => _loadCharges()); // Reload charges when returning
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _generatePaymentReminder(Charge charge) async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final reminderData = {
          'message': 'Nous vous rappelons que votre paiement pour "${charge.titre}" est en attente. Veuillez régler cette charge dès que possible.',
        };

        final result = await _chargeService.generatePaymentReminder(
          charge.id,
          reminderData,
          token,
        );

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Rappel de paiement envoyé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Échec de l\'envoi du rappel de paiement'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isSyndic = userProvider.isSyndic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Charges",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: !isSyndic ? BottomNavigationBar(
        currentIndex: 1, // Charges page is selected
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
            icon: Icon(Icons.euro),
            label: 'Charges',
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
            case 0: // Profile
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProprietaireProfilePage()),
              );
              break;
            case 1: // Charges - already here
              break;
            case 2: // Payments
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentHistoryPage()),
              );
              break;
            case 3: // Notifications
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
              break;
          }
        },
      ) : null,
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
                          onPressed: _loadCharges,
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Summary card for proprietaires
                    if (!isSyndic && _proprietaireName.isNotEmpty)
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
                                "Résumé des charges",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Propriétaire: $_proprietaireName",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total des charges:",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    Charge.formatCurrency(_totalCharges),
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
                                    "Total payé:",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    Charge.formatCurrency(_totalPaid),
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
                                    "Restant à payer:",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    Charge.formatCurrency(_totalRemaining),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Charges list or empty state
                    Expanded(
                      child: _charges.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Aucune charge à afficher',
                                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                  ),
                                  if (isSyndic)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: ElevatedButton(
                                        onPressed: _navigateToCreateCharge,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text('Créer une charge'),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadCharges,
                              child: ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: _charges.length,
                                itemBuilder: (context, index) {
                                  final charge = _charges[index];
                                  final bool isPaid = charge.statut.toLowerCase() == 'payé';
                                  final bool isPartiallyPaid = charge.statut.toLowerCase() == 'partiellement payé';

                                  return Card(
                                    margin: EdgeInsets.only(bottom: 16),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Color(int.parse(Charge.getStatusColor(charge.statut).substring(1, 7), radix: 16) + 0xFF000000).withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Color(int.parse(Charge.getStatusColor(charge.statut).substring(1, 7), radix: 16) + 0xFF000000).withOpacity(0.1),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isPaid ? Icons.check_circle : (isPartiallyPaid ? Icons.timelapse : Icons.warning),
                                                color: Color(int.parse(Charge.getStatusColor(charge.statut).substring(1, 7), radix: 16) + 0xFF000000),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  charge.titre,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Color(int.parse(Charge.getStatusColor(charge.statut).substring(1, 7), radix: 16) + 0xFF000000),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  charge.statut,
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
                                              Text(
                                                charge.description,
                                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                              ),
                                              SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Icon(Icons.euro, size: 16, color: Colors.blue),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Montant: ${Charge.formatCurrency(charge.montant)}',
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
                                                    'Échéance: ${_formatDate(charge.dateEcheance)}',
                                                  ),
                                                ],
                                              ),
                                              if (isPartiallyPaid || !isPaid)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.account_balance_wallet, size: 16, color: Colors.blue),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Restant à payer: ${Charge.formatCurrency(charge.montantRestant)}',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (isPartiallyPaid)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Déjà payé: ${Charge.formatCurrency(charge.montantPaye)}',
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              // Check if montantRestant > 0
                                              if (charge.montantRestant > 0)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.money_off, size: 16, color: Colors.red),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'No payment',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  if (!isPaid && !isSyndic)
                                                    ElevatedButton.icon(
                                                      onPressed: () => _navigateToMakePayment(charge),
                                                      icon: Icon(Icons.payment),
                                                      label: Text('Effectuer un paiement'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                                                        foregroundColor: Colors.white,
                                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                      ),
                                                    ),
                                                  if (!isPaid && isSyndic)
                                                    ElevatedButton.icon(
                                                      onPressed: () => _generatePaymentReminder(charge),
                                                      icon: Icon(Icons.notification_important),
                                                      label: Text('Envoyer un rappel'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.orange,
                                                        foregroundColor: Colors.white,
                                                      ),
                                                    ),
                                                  // Add "Send Client Notice" button if montantRestant > 0
                                                  if (charge.montantRestant > 0)
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 8.0),
                                                      child: ElevatedButton.icon(
                                                        onPressed: () => _generatePaymentReminder(charge),
                                                        icon: Icon(Icons.mail_outline),
                                                        label: Text('Send Client Notice'),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                          foregroundColor: Colors.white,
                                                        ),
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
      floatingActionButton: isSyndic
          ? FloatingActionButton(
              onPressed: _navigateToCreateCharge,
              backgroundColor: const Color.fromARGB(255, 75, 160, 173),
              child: Icon(Icons.add, color: Colors.white),
              tooltip: 'Créer une charge',
            )
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentHistoryPage(),
                  ),
                ).then((_) => _loadCharges());
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.history, color: Colors.white),
              tooltip: 'Historique des paiements',
            ),
    );
  }
}
