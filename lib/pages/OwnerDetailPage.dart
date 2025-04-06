import 'package:flutter/material.dart';
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
        title: Text("Détails du propriétaire",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Nom du propriétaire", widget.owner.name),
            _buildDetailRow("Numéro d'immeuble", widget.owner.numImm.toString()),
            _buildDetailRow("Numéro d'appartement", widget.owner.numApp.toString()),
            _buildDetailRow("Montant à payer", "${widget.owner.amount.toStringAsFixed(2)} MAD"),
            _buildDetailRow("Montant impayé", "${widget.owner.remainingAmount.toStringAsFixed(2)} MAD"),
            _buildDetailRow("Montant réglé", "${widget.owner.paidAmount.toStringAsFixed(2)} MAD"),
            SizedBox(height: 20),

            /// ✅ Bouton centré
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentPage(owner: widget.owner)),
                  );
                  setState(() {}); // Met à jour l'affichage après retour
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 75, 160, 173),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text("Versement"),
              ),
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
