class Payment {
  final String id;
  final double montant;
  final String datePayment;
  final String methodePaiement;
  final String reference;
  final String chargeId;
  final String proprietaireId;
  final String syndicId;
  final String statut;
  final bool isPartial;
  final double remainingAmount;
  final String notes;
  final String? receiptPdfPath;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic>? charge;

  Payment({
    required this.id,
    required this.montant,
    required this.datePayment,
    required this.methodePaiement,
    required this.reference,
    required this.chargeId,
    required this.proprietaireId,
    required this.syndicId,
    required this.statut,
    required this.isPartial,
    required this.remainingAmount,
    required this.notes,
    this.receiptPdfPath,
    required this.createdAt,
    required this.updatedAt,
    this.charge,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      montant: (json['montant'] is int) 
          ? (json['montant'] as int).toDouble() 
          : (json['montant'] ?? 0.0).toDouble(),
      datePayment: json['datePayment'] ?? '',
      methodePaiement: json['methodePaiement'] ?? '',
      reference: json['reference'] ?? '',
      chargeId: json['chargeId'] ?? '',
      proprietaireId: json['proprietaireId'] ?? '',
      syndicId: json['syndicId'] ?? '',
      statut: json['statut'] ?? '',
      isPartial: json['isPartial'] ?? false,
      remainingAmount: (json['remainingAmount'] is int) 
          ? (json['remainingAmount'] as int).toDouble() 
          : (json['remainingAmount'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
      receiptPdfPath: json['receiptPdfPath'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      charge: json['charge'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montant': montant,
      'datePayment': datePayment,
      'methodePaiement': methodePaiement,
      'reference': reference,
      'chargeId': chargeId,
      'proprietaireId': proprietaireId,
      'syndicId': syndicId,
      'statut': statut,
      'isPartial': isPartial,
      'remainingAmount': remainingAmount,
      'notes': notes,
      'receiptPdfPath': receiptPdfPath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'charge': charge,
    };
  }

  // Helper method to get status color
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmé':
      case 'confirmed':
        return '#4CAF50'; // Green
      case 'en attente':
      case 'pending':
        return '#FF9800'; // Orange
      case 'rejeté':
      case 'rejected':
        return '#F44336'; // Red
      default:
        return '#2196F3'; // Blue
    }
  }

  // Helper method to format currency
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} €';
  }
}
