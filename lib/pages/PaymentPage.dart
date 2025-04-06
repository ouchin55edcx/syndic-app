import 'package:flutter/material.dart';
import 'Owner.dart';
import 'AddPaymentPage.dart';

class PaymentPage extends StatefulWidget {
  final Owner owner;

  PaymentPage({required this.owner});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  void _addPayment() async {
    final newPayment = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPaymentPage()),
    );

    if (newPayment != null) {
      setState(() {
        widget.owner.addPayment(newPayment); // Sauvegarde du paiement dans Owner
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Versements de ${widget.owner.name}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow("Montant à payer", "${widget.owner.amount} MAD"),
            _buildDetailRow("Montant impayé", "${widget.owner.remainingAmount} MAD"),
            _buildDetailRow("Montant réglé", "${widget.owner.paidAmount} MAD"),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.owner.payments.length, // Utiliser les paiements stockés
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("Montant : ${widget.owner.payments[index]['montant']}"),
                      subtitle: Text("Date : ${widget.owner.payments[index]['date']} - Mode : ${widget.owner.payments[index]['mode']}"),
                      leading: Icon(Icons.payment, color: Colors.blue),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 0),
            ElevatedButton(
              onPressed: _addPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text("Ajouter un paiement"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}
