class Appartement {
  final String id;
  final String numero;
  final int etage;
  final double superficie;
  final int nombrePieces;
  final String? proprietaireId;
  final String immeubleId;
  final String statut;
  final String createdAt;
  final String updatedAt;

  Appartement({
    required this.id,
    required this.numero,
    required this.etage,
    required this.superficie,
    required this.nombrePieces,
    this.proprietaireId,
    required this.immeubleId,
    required this.statut,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appartement.fromJson(Map<String, dynamic> json) {
    return Appartement(
      id: json['id'] ?? '',
      numero: json['numero'] ?? '',
      etage: json['etage'] ?? 0,
      superficie: (json['superficie'] ?? 0).toDouble(),
      nombrePieces: json['nombrePieces'] ?? 0,
      proprietaireId: json['proprietaireId'],
      immeubleId: json['immeubleId'] ?? '',
      statut: json['statut'] ?? 'disponible',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'etage': etage,
      'superficie': superficie,
      'nombrePieces': nombrePieces,
      'proprietaireId': proprietaireId,
      'immeubleId': immeubleId,
      'statut': statut,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper method to check if apartment is available
  bool get isAvailable => proprietaireId == null || proprietaireId!.isEmpty;
}
