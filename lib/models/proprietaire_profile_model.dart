import '../models/appartement_model.dart';

class ProprietaireProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String role;
  final String createdAt;
  final String updatedAt;
  final String? appartementId;
  final String? ownershipDate;
  final String? createdBy;
  final Appartement? appartement;

  ProprietaireProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.appartementId,
    this.ownershipDate,
    this.createdBy,
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
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      appartementId: json['appartementId'],
      ownershipDate: json['ownershipDate'],
      createdBy: json['createdBy'],
      appartement: json['appartement'] != null 
          ? Appartement.fromJson(json['appartement']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'appartementId': appartementId,
      'ownershipDate': ownershipDate,
      'createdBy': createdBy,
    };
  }

  // Helper method to get full name
  String get fullName => '$firstName $lastName';
  
  // Helper method to get apartment info
  String get apartmentInfo {
    if (appartement != null) {
      return 'Appartement ${appartement!.numero}, Étage ${appartement!.etage}';
    }
    return 'Aucun appartement associé';
  }
}
