import 'package:flutter/material.dart';

class AddPaymentPage extends StatefulWidget {
  @override
  _AddPaymentPageState createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = "Espèces";
  DateTime _selectedDate = DateTime.now();

  // Fonction pour sélectionner la date via un DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  void _savePayment() {
    if (_amountController.text.isNotEmpty) {
      Navigator.pop(context, {
        "montant": "${_amountController.text} MAD",
        "date": _selectedDate.toLocal().toString().split(" ")[0],
        "mode": _selectedMethod,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ajoute un paiement",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champ Montant
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: "Montant",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            // Sélection du mode de paiement
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              onChanged: (String? newValue) => setState(() => _selectedMethod = newValue!),
              decoration: InputDecoration(
                labelText: "Mode de paiement",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              items: ["Espèces", "Carte", "Virement"].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
            ),
            SizedBox(height: 16),

            // Sélection de la date
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(text: "${_selectedDate.toLocal()}".split(" ")[0]),
                  decoration: InputDecoration(
                    labelText: "Date",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Bouton Enregistrer
            Center(
              child: ElevatedButton(
                onPressed: _savePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 75, 160, 173),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text("Enregistrer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
