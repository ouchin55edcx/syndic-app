
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/proprietaire_profile.dart';
import '../services/proprietaire_service.dart';
import '../providers/user_provider.dart';

class ProprietairesListPage extends StatefulWidget {
  @override
  _ProprietairesListPageState createState() => _ProprietairesListPageState();
}

class _ProprietairesListPageState extends State<ProprietairesListPage> {
  final ProprietaireService _proprietaireService = ProprietaireService();
  List<dynamic> _proprietaires = [];
  bool _isLoading = false;
  String _errorMessage = '';

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
          // Debug log
          print('Proprietaires loaded: ${_proprietaires.length}');
          print('First proprietaire: ${_proprietaires.first}');
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
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildProprietaireCard(dynamic proprietaire) {
    // Get the apartment number from the nested appartement object
    final String appartementNumero = proprietaire['appartement']?['numero'] ?? 'Non assigné';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.lightBlue,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${proprietaire['firstName']} ${proprietaire['lastName']}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Appartement $appartementNumero',  // This will now show "Appartement 201"
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Text(
              'Email: ${proprietaire['email']}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            if (proprietaire['appartement'] != null) ...[
              Text(
                'Étage: ${proprietaire['appartement']['etage']}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                'Superficie: ${proprietaire['appartement']['superficie']} m²',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                'Statut: ${proprietaire['appartement']['statut']}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // Handle edit
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    // Handle delete
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Propriétaires'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProprietaires,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _proprietaires.isEmpty
                  ? Center(child: Text('Aucun propriétaire trouvé'))
                  : ListView.builder(
                      itemCount: _proprietaires.length,
                      itemBuilder: (context, index) {
                        return _buildProprietaireCard(_proprietaires[index]);
                      },
                    ),
    );
  }
}
