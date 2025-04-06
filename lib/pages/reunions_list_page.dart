import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/reunion_service.dart';
import '../models/reunion_model.dart';
import 'invite_proprietaires_page.dart';
import 'create_reunion_page.dart';
import 'reunion_details_page.dart';

class ReunionsListPage extends StatefulWidget {
  @override
  _ReunionsListPageState createState() => _ReunionsListPageState();
}

class _ReunionsListPageState extends State<ReunionsListPage> {
  final ReunionService _reunionService = ReunionService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<Reunion> _reunions = [];

  @override
  void initState() {
    super.initState();
    _loadReunions();
  }

  Future<void> _loadReunions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final result = await _reunionService.getMyReunions(token);

        if (result['success']) {
          setState(() {
            _reunions = result['reunions'] as List<Reunion>;
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to load reunions';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred while loading reunions: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'You must be logged in to view your reunions';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToInviteProprietaires(Reunion reunion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InviteProprietairesPage(reunion: reunion),
      ),
    ).then((_) => _loadReunions()); // Reload reunions when returning
  }

  void _navigateToCreateReunion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReunionPage(),
      ),
    ).then((_) => _loadReunions()); // Reload reunions when returning
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mes Réunions",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadReunions,
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : _reunions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Aucune réunion programmée',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _navigateToCreateReunion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Créer une réunion'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadReunions,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _reunions.length,
                        itemBuilder: (context, index) {
                          final reunion = _reunions[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 75, 160, 173),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.event, color: Colors.white),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          reunion.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          reunion.status == 'scheduled' ? 'Programmée' : reunion.status,
                                          style: TextStyle(
                                            color: reunion.status == 'scheduled' ? Colors.green : Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reunion.description,
                                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text(
                                            _formatDate(reunion.date),
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(Icons.access_time, size: 16, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text('${reunion.startTime} - ${reunion.endTime}'),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text(reunion.location),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ReunionDetailsPage(reunionId: reunion.id),
                                              ),
                                            ).then((_) => _loadReunions()),
                                            icon: Icon(Icons.visibility),
                                            label: Text('Détails'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: const Color.fromARGB(255, 75, 160, 173),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          TextButton.icon(
                                            onPressed: () => _navigateToInviteProprietaires(reunion),
                                            icon: Icon(Icons.person_add),
                                            label: Text('Inviter'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: const Color.fromARGB(255, 75, 160, 173),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateReunion,
        backgroundColor: const Color.fromARGB(255, 75, 160, 173),
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Créer une réunion',
      ),
    );
  }
}
