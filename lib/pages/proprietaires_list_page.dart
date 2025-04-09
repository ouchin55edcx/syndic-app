import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/proprietaire_service.dart';
import 'add_proprietaire_page.dart';

class ProprietairesListPage extends StatefulWidget {
  @override
  _ProprietairesListPageState createState() => _ProprietairesListPageState();
}

class _ProprietairesListPageState extends State<ProprietairesListPage> {
  final ProprietaireService _proprietaireService = ProprietaireService();
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _proprietaires = [];
  TextEditingController _searchController = TextEditingController();

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
        // Fetch proprietaires with detailed information including apartments
        final response = await http.get(
          Uri.parse('http://localhost:3000/api/proprietaires?includeDetails=true'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _proprietaires = data['proprietaires'];
            _isLoading = false;
          });

          // Debug output to see the structure of the data
          if (_proprietaires.isNotEmpty) {
            print('First proprietaire data: ${_proprietaires[0]}');
            if (_proprietaires[0]['appartement'] != null) {
              print('Apartment data: ${_proprietaires[0]['appartement']}');
              if (_proprietaires[0]['appartement']['immeuble'] != null) {
                print('Building data: ${_proprietaires[0]['appartement']['immeuble']}');
              }
            }
          }
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load proprietaires';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToAddProprietaire() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProprietairePage()),
    );

    if (result == true) {
      // Refresh the list if a new proprietaire was added
      _loadProprietaires();
    }
  }

  Future<void> _deleteProprietaire(String proprietaireId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/proprietaires/$proprietaireId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Propriétaire supprimé avec succès')),
        );
        _loadProprietaires(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProprietaireCard(Map<String, dynamic> proprietaire) {
    // Simplified approach to get apartment information
    String appartementNumero = '0';
    String immeubleNumero = '1';

    // For debugging
    print('Proprietaire data: $proprietaire');

    // Try to extract apartment number from various possible locations in the data
    try {
      if (proprietaire['appartement'] != null && proprietaire['appartement']['numero'] != null) {
        appartementNumero = proprietaire['appartement']['numero'].toString();
      } else if (proprietaire['appartementNumero'] != null) {
        appartementNumero = proprietaire['appartementNumero'].toString();
      } else if (proprietaire['appartementId'] != null) {
        appartementNumero = proprietaire['appartementId'].toString();
        // Shorten if too long
        if (appartementNumero.length > 5) {
          appartementNumero = appartementNumero.substring(0, 5);
        }
      }
    } catch (e) {
      print('Error getting apartment number: $e');
      appartementNumero = '0';
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Color(0xFF64B5F6), // Light blue color
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${proprietaire['firstName']} ${proprietaire['lastName']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        // Handle edit
                      },
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(8),
                      iconSize: 20,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[100]),
                      onPressed: () => _deleteProprietaire(proprietaire['id']),
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(8),
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Immeuble $immeubleNumero, Appartement $appartementNumero',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Email: ${proprietaire['email']}',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isSyndic = userProvider.isSyndic;

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Propriétaires'),
        backgroundColor: Color.fromARGB(255, 75, 160, 173),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un propriétaire',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Propriétaires API: ${_proprietaires.length}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _loadProprietaires,
                  child: Text('Refresh'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : ListView.builder(
                        itemCount: _proprietaires.length,
                        itemBuilder: (context, index) {
                          return _buildProprietaireCard(_proprietaires[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: isSyndic
          ? FloatingActionButton(
              onPressed: _navigateToAddProprietaire,
              backgroundColor: Colors.black,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
