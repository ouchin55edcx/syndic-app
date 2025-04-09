import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProprietaires();
  }

  Future<void> _loadProprietaires() async {
    debugPrint('Starting to load proprietaires...');
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    debugPrint('User provider token: $token');
    debugPrint('Is user syndic: ${userProvider.isSyndic}');

    if (token != null) {
      try {
        debugPrint('Making API request to fetch proprietaires...');
        final result = await _proprietaireService.getMyProprietaires(token);

        debugPrint('API request completed. Success: ${result['success']}');

        if (result['success']) {
          final proprietaires = result['proprietaires'] ?? [];
          debugPrint('Received ${proprietaires.length} proprietaires');
          
          setState(() {
            _proprietaires = proprietaires;
          });

          // Debug first proprietaire if available
          if (proprietaires.isNotEmpty) {
            debugPrint('First proprietaire: ${proprietaires.first}');
          } else {
            debugPrint('No proprietaires received from API');
          }
        } else {
          debugPrint('API request failed: ${result['message']}');
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to load proprietaires';
          });
        }
      } catch (e, stackTrace) {
        debugPrint('Error while loading proprietaires: $e');
        debugPrint('Stack trace: $stackTrace');
        setState(() {
          _errorMessage = 'An error occurred while loading proprietaires: $e';
        });
      }
    } else {
      debugPrint('No token available - user must be logged in');
      setState(() {
        _errorMessage = 'You must be logged in as a syndic to view proprietaires';
      });
    }

    setState(() {
      _isLoading = false;
    });
    debugPrint('Finished loading proprietaires');
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isSyndic = userProvider.isSyndic;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proprietaires'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _proprietaires.isEmpty
                  ? const Center(
                      child: Text('No proprietaires found'),
                    )
                  : ListView.builder(
                      itemCount: _proprietaires.length,
                      itemBuilder: (context, index) {
                        final proprietaire = _proprietaires[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: ListTile(
                            title: Text(
                              '${proprietaire['firstName']} ${proprietaire['lastName']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${proprietaire['email']}'),
                                Text('Phone: ${proprietaire['phoneNumber']}'),
                                if (proprietaire['appartementId'] != null)
                                  Text('Appartement ID: ${proprietaire['appartementId']}'),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
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
