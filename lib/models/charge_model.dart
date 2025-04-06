class Charge {
  final String id;
  final String titre;
  final String description;
  final double montant;
  final String dateEcheance;
  final String statut;
  final double montantPaye;
  final double montantRestant;
  final String appartementId;
  final String syndicId;
  final String categorie;
  final String? dernierRappel;
  final String createdAt;
  final String updatedAt;

  Charge({
    required this.id,
    required this.titre,
    required this.description,
    required this.montant,
    required this.dateEcheance,
    required this.statut,
    required this.montantPaye,
    required this.montantRestant,
    required this.appartementId,
    required this.syndicId,
    required this.categorie,
    this.dernierRappel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Charge.fromJson(Map<String, dynamic> json) {
    return Charge(
      id: json['id'] ?? '',
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      montant: (json['montant'] is int) 
          ? (json['montant'] as int).toDouble() 
          : (json['montant'] ?? 0.0).toDouble(),
      dateEcheance: json['dateEcheance'] ?? '',
      statut: json['statut'] ?? 'non payé',
      montantPaye: (json['montantPaye'] is int) 
          ? (json['montantPaye'] as int).toDouble() 
          : (json['montantPaye'] ?? 0.0).toDouble(),
      montantRestant: (json['montantRestant'] is int) 
          ? (json['montantRestant'] as int).toDouble() 
          : (json['montantRestant'] ?? 0.0).toDouble(),
      appartementId: json['appartementId'] ?? '',
      syndicId: json['syndicId'] ?? '',
      categorie: json['categorie'] ?? '',
      dernierRappel: json['dernierRappel'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'montant': montant,
      'dateEcheance': dateEcheance,
      'statut': statut,
      'montantPaye': montantPaye,
      'montantRestant': montantRestant,
      'appartementId': appartementId,
      'syndicId': syndicId,
      'categorie': categorie,
      'dernierRappel': dernierRappel,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper method to get status color
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'payé':
      case 'payé intégralement':
      case 'paid':
        return '#4CAF50'; // Green
      case 'partiellement payé':
      case 'partially paid':
        return '#FF9800'; // Orange
      case 'non payé':
      case 'unpaid':
      default:
        return '#F44336'; // Red
    }
  }

  // Helper method to format currency
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} €';
  }
}
