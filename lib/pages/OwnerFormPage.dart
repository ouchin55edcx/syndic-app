import 'package:flutter/material.dart';
import 'Owner.dart';

class OwnerFormPage extends StatefulWidget {
  final Owner? owner;
  final Function(Owner) onSave;

  OwnerFormPage({this.owner, required this.onSave});

  @override
  _OwnerFormPageState createState() => _OwnerFormPageState();
}

class _OwnerFormPageState extends State<OwnerFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numImmController = TextEditingController();
  final TextEditingController numAppController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController contractDateController = TextEditingController(); // Nouveau champ

  @override
  void initState() {
    super.initState();
    if (widget.owner != null) {
      nameController.text = widget.owner!.name;
      numImmController.text = widget.owner!.numImm.toString();
      numAppController.text = widget.owner!.numApp.toString();
      amountController.text = widget.owner!.amount.toString();
      emailController.text = widget.owner!.email;
      telephoneController.text = widget.owner!.phone;
      contractDateController.text = widget.owner!.contractDate.toLocal().toString().split(' ')[0]; // Convertir DateTime en String
    }
  }

  void _saveOwner() {
  if (!_formKey.currentState!.validate()) return;

  final owner = Owner(
    id: widget.owner?.id ?? DateTime.now().millisecondsSinceEpoch,
    name: nameController.text,
    numImm: int.tryParse(numImmController.text) ?? 0,
    numApp: int.tryParse(numAppController.text) ?? 0,
    amount: double.tryParse(amountController.text) ?? 0.0,
    email: emailController.text,
    phone: telephoneController.text,
    contractDate: DateTime.tryParse(contractDateController.text) ?? DateTime.now(),
  );

  widget.onSave(owner);
  Navigator.pop(context);
}


  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.owner != null; // Vérifie si c'est une modification

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (isEditing ? "Modifier Propriétaire" : "Ajouter Propriétaire"),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nom du propriétaire"),
                validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
              ),
              TextFormField(
                controller: numImmController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Numéro d'immeuble"),
                validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
              ),
              TextFormField(
                controller: numAppController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Numéro d'appartement"),
                validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
              ),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Montant à payer"),
                validator: (value) {
                  if (value!.isEmpty) return "Champ obligatoire";
                  final num? parsedValue = double.tryParse(value);
                  if (parsedValue == null) return "Valeur invalide";
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
              ),
              TextFormField(
                controller: telephoneController,
                decoration: InputDecoration(labelText: "Téléphone"),
                validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
              ),
              TextFormField(
  controller: contractDateController,
  readOnly: true, // Empêche la saisie manuelle
  decoration: InputDecoration(
    labelText: "Date de signature du contrat",
    suffixIcon: IconButton(
      icon: Icon(Icons.calendar_today),
      onPressed: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            contractDateController.text = pickedDate.toLocal().toString().split(' ')[0];
          });
        }
      },
    ),
  ),
  validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveOwner,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 75, 160, 173), foregroundColor: Colors.white),
                    child: Text(isEditing ? "Modifier" : "Enregistrer"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 75, 160, 173), foregroundColor: Colors.white),
                    child: Text("Annuler"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
