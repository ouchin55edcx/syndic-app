import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Owner.dart';
import 'OwnerFormPage.dart';
import 'notifications_page.dart';
import '../widgets/NotificationBell.dart';
import '../widgets/user_avatar.dart';
import 'UserProfilePage.dart';
import 'OwnerDetailPage.dart';
import '../providers/user_provider.dart';
import '../services/proprietaire_service.dart';
import 'add_proprietaire_page.dart';

class OwnersListPage extends StatefulWidget {
  @override
  _OwnersListPageState createState() => _OwnersListPageState();
}

class _OwnersListPageState extends State<OwnersListPage> {
  final ProprietaireService _proprietaireService = ProprietaireService();
  List<Owner> owners = [];
  List<Owner> filteredOwners = [];
  List<dynamic> _apiProprietaires = [];
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    filteredOwners = owners;
    searchController.addListener(_filterOwners);
    _loadProprietaires();
  }

  Future<void> _loadProprietaires() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    debugPrint('Loading proprietaires with token: $token');

    if (token != null && userProvider.isSyndic) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final result = await _proprietaireService.getMyProprietaires(token);

        if (result['success']) {
          setState(() {
            _apiProprietaires = result['proprietaires'] ?? [];
            // Convert API proprietaires to Owner objects for compatibility
            _convertApiProprietairesToOwners();
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to load proprietaires';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred while loading proprietaires';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _convertApiProprietairesToOwners() {
    // Convert API proprietaires to Owner objects
    List<Owner> newOwners = [];
    for (var proprietaire in _apiProprietaires) {
      newOwners.add(Owner(
        id: int.tryParse(proprietaire['id'] ?? '0') ?? 0,
        name: '${proprietaire['firstName'] ?? ''} ${proprietaire['lastName'] ?? ''}',
        numImm: 1, // Default values since API might not have these fields
        numApp: int.tryParse(proprietaire['appartementId']?.toString() ?? '0') ?? 0,
        amount: 0.0, // Default value
        phone: proprietaire['phoneNumber'] ?? '',
        email: proprietaire['email'] ?? '',
        contractDate: proprietaire['ownershipDate'] != null
            ? DateTime.parse(proprietaire['ownershipDate'])
            : DateTime.now(),
      ));
    }

    setState(() {
      owners = newOwners;
      _filterOwners();
    });
  }

  void _filterOwners() {
    setState(() {
      filteredOwners = owners
          .where((owner) => owner.name.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _addOrUpdateOwner(Owner owner) {
    setState(() {
      int index = owners.indexWhere((o) => o.id == owner.id);
      if (index >= 0) {
        owners[index] = owner;
      } else {
        owners.add(owner);
      }
      _filterOwners();
    });
  }

  void _editOwner(Owner owner) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OwnerFormPage(
          owner: owner,
          onSave: _addOrUpdateOwner,
        ),
      ),
    );
  }

  void _deleteOwner(Owner owner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content: Text("Voulez-vous vraiment supprimer ${owner.name} ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  owners.removeWhere((o) => o.id == owner.id);
                  _filterOwners();
                });
                Navigator.pop(context);
              },
              child: Text("Supprimer", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _addOwner() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.token != null && userProvider.isSyndic) {
      // Use the API-based form for syndic users
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddProprietairePage(),
        ),
      );

      if (result == true) {
        // Refresh the list if a new proprietaire was added
        _loadProprietaires();
      }
    } else {
      // Use the original form for non-syndic users or when not authenticated
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OwnerFormPage(
            onSave: _addOrUpdateOwner,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isSyndic = userProvider.isSyndic;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        elevation: 0,
        title: Text(
          "Liste Des Propriétaires",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
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
                          onPressed: _loadProprietaires,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: "Rechercher un propriétaire",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (isSyndic && _apiProprietaires.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              'Propriétaires API: ${_apiProprietaires.length}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: _loadProprietaires,
                              child: Text('Refresh'),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: filteredOwners.isEmpty
                          ? Center(
                              child: Text(
                                "Aucun propriétaire trouvé.",
                                style: TextStyle(fontSize: 18, color: Colors.black54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredOwners.length,
                              itemBuilder: (context, index) {
                                final owner = filteredOwners[index];
                                return Card(
                                  color: Colors.blue.withOpacity(0.6),
                                  margin: EdgeInsets.all(8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OwnerDetailPage(owner: owner),
                                        ),
                                      );
                                    },
                                    title: Text(
                                      owner.name,
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Immeuble ${owner.numImm}, Appartement ${owner.numApp}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        if (owner.amount > 0)
                                          Text(
                                            "Montant à payer: ${owner.amount.toStringAsFixed(2)} MAD",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        Text(
                                          "Email: ${owner.email}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.white),
                                          onPressed: () => _editOwner(owner),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteOwner(owner),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOwner,
        backgroundColor: const Color.fromARGB(255, 75, 160, 173),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
