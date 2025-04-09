import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Owner.dart';
import 'PaymentPage.dart';

class OwnerDetailPage extends StatefulWidget {
  final Owner owner;

  OwnerDetailPage({required this.owner});

  @override
  _OwnerDetailPageState createState() => _OwnerDetailPageState();
}

class _OwnerDetailPageState extends State<OwnerDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détails du propriétaire"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Nom", widget.owner.name),
            _buildDetailRow("Immeuble", widget.owner.numImm.toString()),
            _buildDetailRow("Appartement", widget.owner.numApp.toString()),
            _buildDetailRow("Montant impayé", "${widget.owner.remainingAmount.toStringAsFixed(2)} MAD"),
            _buildDetailRow("Montant réglé", "${widget.owner.paidAmount.toStringAsFixed(2)} MAD"),
            _buildDetailRow("Téléphone", widget.owner.phone),
            _buildDetailRow("Email", widget.owner.email),
            _buildDetailRow("Date du contrat", 
              DateFormat('dd/MM/yyyy').format(widget.owner.contractDate)),
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
