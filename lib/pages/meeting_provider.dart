import 'package:flutter/material.dart';

class Meeting {
  final String date;
  final String time;
  final String agenda;
  final String location;

  Meeting({
    required this.date,
    required this.time,
    required this.agenda,
    required this.location,
  });
}

class MeetingProvider extends ChangeNotifier {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _agenda = "";
  String _location = "";
  final List<Meeting> _meetings = [];

  final TextEditingController agendaController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  String get agenda => _agenda;
  String get location => _location;
  List<Meeting> get meetings => _meetings;

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setTime(TimeOfDay time) {
    _selectedTime = time;
    notifyListeners();
  }

  void setAgenda(String agenda) {
    _agenda = agenda;
    agendaController.text = agenda;
    notifyListeners();
  }

  void setLocation(String location) {
    _location = location;
    locationController.text = location;
    notifyListeners();
  }

  /// Enregistrer la réunion après vérification des champs
  Future<void> saveMeeting(BuildContext context) async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _agenda.isEmpty ||
        _location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ajouter la réunion à la liste
    final meeting = Meeting(
      date:
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
      time: _selectedTime!.format(context),
      agenda: _agenda,
      location: _location,
    );
    _meetings.add(meeting);
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("veuillez attendez ..."),
        backgroundColor: Color.fromARGB(255, 74, 77, 74),
      ),
    );

    clearFields();
  }

  /// Réinitialiser les champs après l'enregistrement
  void clearFields() {
    _selectedDate = null;
    _selectedTime = null;
    _agenda = "";
    _location = "";
    agendaController.clear();
    locationController.clear();
    notifyListeners();
  }

  /// Supprimer une réunion spécifique
  void deleteMeeting(int index) {
    _meetings.removeAt(index);
    notifyListeners();
  }

  void updateMeeting(int index, BuildContext context) {
    if (index < 0 || index >= _meetings.length) return;

    final oldMeeting = _meetings[index];

    _meetings[index] = Meeting(
      date:
          _selectedDate != null
              ? "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}"
              : oldMeeting.date, // Garde l'ancienne date si non modifiée
      time:
          _selectedTime != null
              ? _selectedTime!.format(context)
              : oldMeeting.time, // Garde l'ancienne heure si non modifiée
      agenda:
          _agenda.isNotEmpty
              ? _agenda
              : oldMeeting.agenda, // Garde l'ancien agenda si non modifié
      location:
          _location.isNotEmpty
              ? _location
              : oldMeeting.location, // Garde l'ancien lieu si non modifié
    );

    notifyListeners();
    clearFields(); // Réinitialise les champs après modification
  }
}
