import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/proprietaire_service.dart';
import '../services/reunion_service.dart';
import '../models/reunion_model.dart';
import 'reunions_list_page.dart';

class InviteProprietairesPage extends StatefulWidget {
  final Reunion reunion;

  InviteProprietairesPage({required this.reunion});

  @override
  _InviteProprietairesPageState createState() => _InviteProprietairesPageState();
}

class _InviteProprietairesPageState extends State<InviteProprietairesPage> {
  final ProprietaireService _proprietaireService = ProprietaireService();
  final ReunionService _reunionService = ReunionService();

  bool _isLoading = true;
  bool _isInviting = false;
  String _errorMessage = '';
  String _successMessage = '';
  List<dynamic> _proprietaires = [];
  Set<String> _selectedProprietaireIds = {};

  @override
  void initState() {
    super.initState();
    _loadProprietaires();
  }

  Future<void> _loadProprietaires() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final result = await _proprietaireService.getMyProprietaires(token);

        if (result['success']) {
          setState(() {
            _proprietaires = result['proprietaires'] ?? [];
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to load proprietaires';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred while loading proprietaires: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'You must be logged in as a syndic to view proprietaires';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _inviteProprietaires() async {
    if (_selectedProprietaireIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner au moins un propriétaire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isInviting = true;
      _errorMessage = '';
      _successMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final result = await _reunionService.inviteProprietaires(
          widget.reunion.id,
          _selectedProprietaireIds.toList(),
          token,
        );

        if (result['success']) {
          setState(() {
            _successMessage = result['message'] ?? 'Propriétaires invités avec succès';
            _selectedProprietaireIds.clear(); // Clear selection after successful invitation
          });

          // Show success message for a moment, then navigate to reunions list
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ReunionsListPage()),
            );
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Échec de l\'invitation des propriétaires';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur est survenue: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Vous devez être connecté en tant que syndic pour inviter des propriétaires';
      });
    }

    setState(() {
      _isInviting = false;
    });
  }

  void _toggleProprietaireSelection(String proprietaireId) {
    setState(() {
      if (_selectedProprietaireIds.contains(proprietaireId)) {
        _selectedProprietaireIds.remove(proprietaireId);
      } else {
        _selectedProprietaireIds.add(proprietaireId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Inviter des propriétaires",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Reunion info card
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
                    widget.reunion.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.reunion.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(widget.reunion.date),
                      SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text('${widget.reunion.startTime} - ${widget.reunion.endTime}'),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(widget.reunion.location),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Error and success messages
          if (_errorMessage.isNotEmpty)
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),

          if (_successMessage.isNotEmpty)
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _successMessage,
                style: TextStyle(color: Colors.green),
              ),
            ),

          // Proprietaires list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _proprietaires.isEmpty
                    ? Center(child: Text('Aucun propriétaire disponible'))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _proprietaires.length,
                        itemBuilder: (context, index) {
                          final proprietaire = _proprietaires[index];
                          final proprietaireId = proprietaire['id'] ?? '';
                          final isSelected = _selectedProprietaireIds.contains(proprietaireId);

                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                '${proprietaire['firstName'] ?? ''} ${proprietaire['lastName'] ?? ''}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${proprietaire['email'] ?? ''}'),
                                  Text('Téléphone: ${proprietaire['phoneNumber'] ?? ''}'),
                                ],
                              ),
                              value: isSelected,
                              onChanged: (bool? value) {
                                if (value != null && proprietaireId.isNotEmpty) {
                                  _toggleProprietaireSelection(proprietaireId);
                                }
                              },
                              secondary: CircleAvatar(
                                backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                                child: Text(
                                  (proprietaire['firstName'] ?? '').isNotEmpty
                                      ? (proprietaire['firstName'] as String).substring(0, 1).toUpperCase()
                                      : '?',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              activeColor: Colors.blue,
                              checkColor: Colors.white,
                              controlAffinity: ListTileControlAffinity.trailing,
                            ),
                          );
                        },
                      ),
          ),

          // Invite button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isInviting ? null : _inviteProprietaires,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isInviting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Inviter les propriétaires sélectionnés',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
