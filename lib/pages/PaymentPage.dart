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
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedPaymentMode = 'Espèces';
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paiement"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Propriétaire", widget.owner.name),
            _buildDetailRow("Montant impayé", "${widget.owner.remainingAmount.toStringAsFixed(2)} MAD"),
            _buildDetailRow("Montant réglé", "${widget.owner.paidAmount.toStringAsFixed(2)} MAD"),
            
            SizedBox(height: 20),
            Text("Historique des paiements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.owner.payments.length,
              itemBuilder: (context, index) {
                final payment = widget.owner.payments[index];
                return Card(
                  child: ListTile(
                    title: Text("Montant : ${payment['montant']} MAD"),
                    subtitle: Text("Date : ${payment['date']} - Mode : ${payment['mode']}"),
                  ),
                );
              },
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
