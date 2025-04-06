import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';
import '../services/reunion_service.dart';
import '../models/notification_model.dart' as app_notification;
import 'proprietaire_profile_page.dart';
import 'charges_list_page.dart';
import 'payment_history_page.dart';
import 'home_screen.dart';
// import 'package:url_launcher/url_launcher_string.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  final ReunionService _reunionService = ReunionService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<app_notification.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final result = await _notificationService.getNotifications(token);

        if (result['success']) {
          setState(() {
            _notifications = result['notifications'] as List<app_notification.Notification>;
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to load notifications';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred while loading notifications: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'You must be logged in to view your notifications';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _respondToReunionInvitation(String reunionId, String status, String notificationId) async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final result = await _reunionService.updateInvitationStatus(
          reunionId,
          status,
          token,
        );

        if (result['success']) {
          // Mark the notification as read
          await _markAsRead(notificationId);

          // Update the local notification to show it's been responded to
          setState(() {
            final index = _notifications.indexWhere((n) => n.id == notificationId);
            if (index != -1) {
              // Create a new notification with updated metadata
              final updatedNotification = app_notification.Notification(
                id: _notifications[index].id,
                userId: _notifications[index].userId,
                title: _notifications[index].title,
                message: '${_notifications[index].message}\n\nVous avez ${status == 'accepted' ? 'accepté' : 'décliné'} cette invitation.',
                type: _notifications[index].type,
                relatedTo: _notifications[index].relatedTo,
                relatedId: _notifications[index].relatedId,
                pdfUrl: _notifications[index].pdfUrl,
                read: true,
                createdAt: _notifications[index].createdAt,
                updatedAt: DateTime.now().toIso8601String(),
              );

              // Replace the old notification with the updated one
              _notifications[index] = updatedNotification;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Invitation ${status == 'accepted' ? 'acceptée' : 'déclinée'} avec succès'),
              backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Échec de la réponse à l\'invitation'),
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

  Future<void> _markAsRead(String notificationId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final result = await _notificationService.markAsRead(notificationId, token);
        if (result['success']) {
          // Update the local notification to show as read
          setState(() {
            final index = _notifications.indexWhere((n) => n.id == notificationId);
            if (index != -1) {
              final updatedNotification = app_notification.Notification(
                id: _notifications[index].id,
                userId: _notifications[index].userId,
                title: _notifications[index].title,
                message: _notifications[index].message,
                type: _notifications[index].type,
                relatedTo: _notifications[index].relatedTo,
                relatedId: _notifications[index].relatedId,
                pdfUrl: _notifications[index].pdfUrl,
                read: true,
                createdAt: _notifications[index].createdAt,
                updatedAt: _notifications[index].updatedAt,
              );
              _notifications[index] = updatedNotification;
            }
          });
        }
      } catch (e) {
        debugPrint('Error marking notification as read: $e');
      }
    }
  }

  void _openPdf(String? pdfUrl) {
    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aucun document disponible'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final url = 'http://localhost:3000$pdfUrl';

    // Afficher une boîte de dialogue avec des options pour le PDF
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Document PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Que souhaitez-vous faire avec ce document?'),
              SizedBox(height: 16),
              Text(
                'URL: $url',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _viewPdf(url);
              },
              icon: Icon(Icons.visibility),
              label: Text('Visualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadPdf(url);
              },
              icon: Icon(Icons.download),
              label: Text('Télécharger'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _viewPdf(String url) {
    // Afficher le PDF dans le navigateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture du document: $url'),
        duration: Duration(seconds: 5),
      ),
    );

    // Note: Dans une application réelle, vous utiliseriez url_launcher ou un plugin PDF viewer
    // pour ouvrir le PDF dans le navigateur ou dans une visionneuse intégrée
  }

  void _downloadPdf(String url) {
    // Télécharger le PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement du document: $url'),
        duration: Duration(seconds: 5),
      ),
    );

    // Note: Dans une application réelle, vous utiliseriez un plugin comme dio ou http
    // pour télécharger le fichier et le sauvegarder dans le stockage de l'appareil
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Notifications page is selected
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        selectedItemColor: const Color.fromARGB(255, 75, 160, 173),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Important for more than 3 items
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.euro),
            label: 'Charges',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Paiements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0: // Profile
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProprietaireProfilePage()),
              );
              break;
            case 1: // Charges
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ChargesListPage()),
              );
              break;
            case 2: // Payments
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentHistoryPage()),
              );
              break;
            case 3: // Notifications - already here
              break;
          }
        },
      ),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Notifications",
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
                          onPressed: _loadNotifications,
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune notification',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: notification.read ? 1 : 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: notification.read
                                    ? Colors.transparent
                                    : notification.color.withOpacity(0.5),
                                width: notification.read ? 0 : 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () => _markAsRead(notification.id),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: notification.color.withOpacity(0.2),
                                          child: Icon(notification.icon, color: notification.color),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notification.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                _formatDate(notification.createdAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!notification.read)
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: notification.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      notification.message,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    // Add reunion response UI based on status
                                    if (notification.relatedTo == 'reunion')
                                      Builder(builder: (context) {
                                        // Check if already responded
                                        final bool hasResponded =
                                            notification.message.contains('Vous avez accepté') ||
                                            notification.message.contains('Vous avez décliné');

                                        if (hasResponded) {
                                          // Show response status if already responded
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 12.0),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: notification.message.contains('accepté') ?
                                                       Colors.green.withOpacity(0.2) :
                                                       Colors.red.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                notification.message.contains('accepté') ?
                                                  'Vous avez accepté cette invitation' :
                                                  'Vous avez décliné cette invitation',
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: notification.message.contains('accepté') ?
                                                         Colors.green :
                                                         Colors.red,
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Show buttons if not responded yet
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 12.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () => _respondToReunionInvitation(
                                                    notification.relatedId,
                                                    'accepted',
                                                    notification.id,
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                                  ),
                                                  child: Text('Accepter'),
                                                ),
                                                SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () => _respondToReunionInvitation(
                                                    notification.relatedId,
                                                    'declined',
                                                    notification.id,
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                                  ),
                                                  child: Text('Décliner'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }),
                                    // Affichage spécial pour les avis clients avec PDF
                                    if (notification.pdfUrl != null && notification.pdfUrl!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.picture_as_pdf, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Document PDF disponible',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Ce document contient des informations importantes concernant votre propriété.',
                                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                              ),
                                              SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () => _openPdf(notification.pdfUrl),
                                                    icon: Icon(Icons.open_in_new),
                                                    label: Text('Ouvrir le document'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.blue,
                                                      foregroundColor: Colors.white,
                                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return "Aujourd'hui à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      } else if (difference.inDays == 1) {
        return "Hier à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      } else if (difference.inDays < 7) {
        return "Il y a ${difference.inDays} jours";
      } else {
        return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      }
    } catch (e) {
      return dateString;
    }
  }
}


