import 'package:flutter/material.dart';

class VersementScreen extends StatefulWidget {
  @override
  _VersementScreenState createState() => _VersementScreenState();
}

class _VersementScreenState extends State<VersementScreen> {
  String selectedImm = "8";
  String selectedAppt = "8";
  List<Map<String, String>> versements = [];

  void _ajouterVersement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjouterVersementScreen(onAjout: (versement) {
          setState(() {
            versements.add(versement);
          });
        }),
      ),
    );
  }

  void _supprimerVersement(int index) {
    setState(() {
      versements.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GESTION SYNDICAT"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedImm,
                    items: ["8", "9", "10"].map((e) => DropdownMenuItem(value: e, child: Text("Immeuble $e"))).toList(),
                    onChanged: (val) => setState(() => selectedImm = val!),
                    decoration: InputDecoration(labelText: "Num_IMM", border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedAppt,
                    items: ["8", "9", "10"].map((e) => DropdownMenuItem(value: e, child: Text("Appt $e"))).toList(),
                    onChanged: (val) => setState(() => selectedAppt = val!),
                    decoration: InputDecoration(labelText: "Num_Appt", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: versements.isEmpty
                  ? Center(child: Text("Aucun versement enregistré."))
                  : ListView.builder(
                      itemCount: versements.length,
                      itemBuilder: (context, index) {
                        final v = versements[index];
                        return Card(
                          child: ListTile(
                            title: Text("${v['date']} - ${v['montant']} DH"),
                            subtitle: Text("Mode: ${v['mode']} | Réf: ${v['ref']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _supprimerVersement(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: _ajouterVersement,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
              child: Text("Effectuer un versement"),
            ),
          ],
        ),
      ),
    );
  }
}

class AjouterVersementScreen extends StatefulWidget {
  final Function(Map<String, String>) onAjout;
  AjouterVersementScreen({required this.onAjout});

  @override
  _AjouterVersementScreenState createState() => _AjouterVersementScreenState();
}

class _AjouterVersementScreenState extends State<AjouterVersementScreen> {
  final _formKey = GlobalKey<FormState>();
  String montant = "";
  String mode = "Espèce";
  String reference = "";
  String date = "";

  void _validerVersement() {
    if (_formKey.currentState!.validate()) {
      widget.onAjout({"date": date, "montant": montant, "mode": mode, "ref": reference});
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter un Versement"), backgroundColor: Colors.blue.shade700),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Date", border: OutlineInputBorder()),
                onChanged: (val) => date = val,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: "Montant", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (val) => montant = val,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: mode,
                items: ["Espèce", "Chèque", "Virement"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => mode = val!),
                decoration: InputDecoration(labelText: "Mode de paiement", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: "Référence", border: OutlineInputBorder()),
                onChanged: (val) => reference = val,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validerVersement,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                child: Text("Valider"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
