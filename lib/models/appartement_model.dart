class Appartement {
  final String id;
  final String numero;
  final int etage;
  final double superficie;
  final int nombrePieces;
  final String proprietaireId;
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
    required this.proprietaireId,
    required this.immeubleId,
    required this.statut,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appartement.fromJson(Map<String, dynamic> json) {
    return Appartement(
      id: json['id'] ?? '',
      numero: json['numero'] ?? '',
      etage: int.parse(json['etage'].toString()),
      superficie: double.parse(json['superficie'].toString()),
      nombrePieces: int.parse(json['nombrePieces'].toString()),
      proprietaireId: json['proprietaireId'] ?? '',
      immeubleId: json['immeubleId'] ?? '',
      statut: json['statut'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
