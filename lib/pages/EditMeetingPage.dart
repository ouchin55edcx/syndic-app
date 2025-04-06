import 'package:flutter/material.dart';
import 'meeting_provider.dart';
import 'package:provider/provider.dart';

class EditMeetingPage extends StatefulWidget {
  final int index;

  const EditMeetingPage({super.key, required this.index});

  @override
  _EditMeetingPageState createState() => _EditMeetingPageState();
}

class _EditMeetingPageState extends State<EditMeetingPage> {
  late TextEditingController agendaController;
  late TextEditingController locationController;
  final _formKey = GlobalKey<FormState>(); // Clé pour le formulaire

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MeetingProvider>(context, listen: false);
    final meeting = provider.meetings[widget.index];

    // Initialisation des champs
    agendaController = TextEditingController(text: meeting.agenda);
    locationController = TextEditingController(text: meeting.location);

    // Vous pouvez initialiser la date et l'heure ici si nécessaire
  }

  @override
  void dispose() {
    agendaController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void _saveMeeting() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<MeetingProvider>(context, listen: false);
      provider.updateMeeting(widget.index, context);
      provider.clearFields(); // Réinitialiser les champs après modification
      Navigator.pop(context); // Retour à la liste des réunions
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MeetingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Modifier la réunion",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Associe la clé du formulaire
          child: Column(
            children: [
              // Champ de texte pour l'agenda
              TextFormField(
                controller: agendaController,
                decoration: InputDecoration(
                  labelText: "Ordre du jour",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'ordre du jour';
                  }
                  return null;
                },
                onChanged: (value) => provider.setAgenda(value),
              ),
              const SizedBox(height: 10),

              // Champ de texte pour la localisation
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: "Lieu",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le lieu';
                  }
                  return null;
                },
                onChanged: (value) => provider.setLocation(value),
              ),
              const SizedBox(height: 10),

              // Sélecteur de date
              ListTile(
                title: const Text("Date de la réunion"),
                subtitle: Text(provider.selectedDate != null
                    ? "${provider.selectedDate!.year}-${provider.selectedDate!.month.toString().padLeft(2, '0')}-${provider.selectedDate!.day.toString().padLeft(2, '0')}"
                    : "Sélectionner une date"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),

              // Sélecteur d'heure
              ListTile(
                title: const Text("Heure de la réunion"),
                subtitle: Text(provider.selectedTime != null
                    ? provider.selectedTime!.format(context)
                    : "Sélectionner une heure"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),

              const SizedBox(height: 20),

              // Bouton pour enregistrer les modifications
              ElevatedButton(
                onPressed: _saveMeeting,
                child: Text("Enregistrer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ouvrir le sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final provider = Provider.of<MeetingProvider>(context, listen: false);
    DateTime initialDate = provider.selectedDate ?? DateTime.now();
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    
    if (picked != null) {
      provider.setDate(picked);
    }
  }

  /// Ouvrir le sélecteur d'heure
  Future<void> _selectTime(BuildContext context) async {
    final provider = Provider.of<MeetingProvider>(context, listen: false);
    TimeOfDay initialTime = provider.selectedTime ?? TimeOfDay.now();
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (picked != null) {
      provider.setTime(picked);
    }
  }
}
