import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/reunion_service.dart';
import '../models/reunion_model.dart';

class ReunionDetailsPage extends StatefulWidget {
  final String reunionId;

  ReunionDetailsPage({required this.reunionId});

  @override
  _ReunionDetailsPageState createState() => _ReunionDetailsPageState();
}

class _ReunionDetailsPageState extends State<ReunionDetailsPage> {
  final ReunionService _reunionService = ReunionService();
  bool _isLoading = true;
  String _errorMessage = '';
  Reunion? _reunion;
  List<dynamic> _invitations = [];
  String _reunionTitle = '';
  String _reunionDate = '';

  @override
  void initState() {
    super.initState();
    _loadReunionDetails();
  }

  Future<void> _loadReunionDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        // First, get the basic reunion details
        final detailsResult = await _reunionService.getReunionDetails(widget.reunionId, token);

        if (detailsResult['success']) {
          setState(() {
            _reunion = detailsResult['reunion'];
          });

          // Then, get the invitations
          final invitationsResult = await _reunionService.getReunionInvitations(widget.reunionId, token);

          if (invitationsResult['success']) {
            setState(() {
              _invitations = invitationsResult['invitations'] ?? [];
              _reunionTitle = invitationsResult['reunionTitle'] ?? '';
              _reunionDate = invitationsResult['reunionDate'] ?? '';
            });
          } else {
            setState(() {
              _errorMessage = invitationsResult['message'] ?? 'Failed to load invitations';
            });
          }
        } else {
          setState(() {
            _errorMessage = detailsResult['message'] ?? 'Failed to load reunion details';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred while loading reunion details: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'You must be logged in to view reunion details';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateAttendance(String relationshipId, String proprietaireId, String attendance) async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null && _reunion != null) {
      try {
        final result = await _reunionService.updateAttendance(
          _reunion!.id,
          proprietaireId,
          attendance,
          token,
        );

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Présence mise à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          // Update the local state to avoid reloading everything
          setState(() {
            for (int i = 0; i < _invitations.length; i++) {
              if (_invitations[i]['relationship']['id'] == relationshipId) {
                _invitations[i]['relationship']['attendance'] = attendance;
                break;
              }
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Échec de la mise à jour de la présence'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
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
          "Détails de la réunion",
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
                          onPressed: _loadReunionDetails,
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : _reunion == null
                  ? Center(child: Text('Aucune information disponible'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    _reunion!.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _reunion!.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                                      SizedBox(width: 4),
                                      Text(_formatDate(_reunion!.date)),
                                      SizedBox(width: 16),
                                      Icon(Icons.access_time, size: 16, color: Colors.blue),
                                      SizedBox(width: 4),
                                      Text('${_reunion!.startTime} - ${_reunion!.endTime}'),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 16, color: Colors.blue),
                                      SizedBox(width: 4),
                                      Text(_reunion!.location),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline, size: 16, color: Colors.blue),
                                      SizedBox(width: 4),
                                      Text('Statut: ${_reunion!.status}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Invited proprietaires list
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Text(
                                  'Propriétaires invités',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_invitations.length}',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _invitations.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('Aucun propriétaire invité'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _invitations.length,
                                  itemBuilder: (context, index) {
                                    final invitation = _invitations[index];
                                    final relationship = invitation['relationship'] ?? {};
                                    final proprietaire = invitation['proprietaire'] ?? {};

                                    final relationshipId = relationship['id'] ?? '';
                                    final proprietaireId = proprietaire['id'] ?? '';
                                    final proprietaireName = '${proprietaire['firstName'] ?? ''} ${proprietaire['lastName'] ?? ''}';
                                    final proprietaireEmail = proprietaire['email'] ?? '';
                                    final proprietairePhone = proprietaire['phoneNumber'] ?? '';
                                    final invitationStatus = relationship['status'] ?? 'pending';
                                    final attendance = relationship['attendance'] ?? 'pending';

                                    return Card(
                                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: _getStatusColor(invitationStatus).withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                                                  child: Text(
                                                    proprietaireName.isNotEmpty
                                                        ? proprietaireName.substring(0, 1).toUpperCase()
                                                        : '?',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        proprietaireName,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        proprietaireEmail,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                      if (proprietairePhone.isNotEmpty)
                                                        Text(
                                                          proprietairePhone,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(invitationStatus),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    _getStatusText(invitationStatus),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (invitationStatus == 'accepted')
                                              Padding(
                                                padding: const EdgeInsets.only(top: 12.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Divider(),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.event_available, size: 16, color: Colors.blue),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Présence:',
                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: _getAttendanceColor(attendance),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Text(
                                                            _getAttendanceText(attendance),
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        ElevatedButton(
                                                          onPressed: () => _updateAttendance(relationshipId, proprietaireId, 'present'),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: attendance == 'present' ? Colors.green : Colors.grey[300],
                                                            foregroundColor: attendance == 'present' ? Colors.white : Colors.black,
                                                            padding: EdgeInsets.symmetric(horizontal: 12),
                                                          ),
                                                          child: Text('Présent'),
                                                        ),
                                                        SizedBox(width: 8),
                                                        ElevatedButton(
                                                          onPressed: () => _updateAttendance(relationshipId, proprietaireId, 'absent'),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: attendance == 'absent' ? Colors.red : Colors.grey[300],
                                                            foregroundColor: attendance == 'absent' ? Colors.white : Colors.black,
                                                            padding: EdgeInsets.symmetric(horizontal: 12),
                                                          ),
                                                          child: Text('Absent'),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'invited':
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepté';
      case 'declined':
        return 'Décliné';
      case 'invited':
        return 'Invité';
      case 'pending':
      default:
        return 'En attente';
    }
  }

  Color _getAttendanceColor(String attendance) {
    switch (attendance) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'pending':
      default:
        return Colors.grey;
    }
  }

  String _getAttendanceText(String attendance) {
    switch (attendance) {
      case 'present':
        return 'Présent';
      case 'absent':
        return 'Absent';
      case 'pending':
      default:
        return 'Non défini';
    }
  }
}
