import '../models/appartement_model.dart';

class ProprietaireProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String role;
  final String? appartementId;
  final DateTime? ownershipDate;
  final String createdAt;
  final String updatedAt;
  Appartement? appartement;

  String get fullName => '$firstName $lastName';

  ProprietaireProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    this.appartementId,
    this.ownershipDate,
    required this.createdAt,
    required this.updatedAt,
    this.appartement,
  });

  factory ProprietaireProfile.fromJson(Map<String, dynamic> json) {
    return ProprietaireProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      appartementId: json['appartementId'],
      ownershipDate: json['ownershipDate'] != null 
          ? DateTime.parse(json['ownershipDate'])
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
