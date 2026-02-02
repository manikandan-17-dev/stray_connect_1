import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stray_resuce_bih/core/models/enums.dart';

/// User model representing all user types in the system
class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String city;
  final GeoPoint location;
  final bool verified;
  final DateTime createdAt;
  
  // Role-specific fields
  final String? organizationName; // For NGO
  final String? registrationNumber; // For NGO/Vet
  final String? licenseNumber; // For Vet
  final String? clinicName; // For Vet
  final bool? availability; // For Volunteer/Vet
  final String? transport; // For Volunteer (bike/car/none)
  final String? areaOfOperation; // For Volunteer

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    required this.city,
    required this.location,
    this.verified = false,
    required this.createdAt,
    this.organizationName,
    this.registrationNumber,
    this.licenseNumber,
    this.clinicName,
    this.availability,
    this.transport,
    this.areaOfOperation,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.value,
      'city': city,
      'location': location,
      'verified': verified,
      'createdAt': Timestamp.fromDate(createdAt),
      if (organizationName != null) 'organizationName': organizationName,
      if (registrationNumber != null) 'registrationNumber': registrationNumber,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      if (clinicName != null) 'clinicName': clinicName,
      if (availability != null) 'availability': availability,
      if (transport != null) 'transport': transport,
      if (areaOfOperation != null) 'areaOfOperation': areaOfOperation,
    };
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      name: data['name'] as String,
      phone: data['phone'] as String,
      email: data['email'] as String?,
      role: UserRole.fromString(data['role'] as String),
      city: data['city'] as String,
      location: data['location'] as GeoPoint,
      verified: data['verified'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      organizationName: data['organizationName'] as String?,
      registrationNumber: data['registrationNumber'] as String?,
      licenseNumber: data['licenseNumber'] as String?,
      clinicName: data['clinicName'] as String?,
      availability: data['availability'] as bool?,
      transport: data['transport'] as String?,
      areaOfOperation: data['areaOfOperation'] as String?,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    String? city,
    GeoPoint? location,
    bool? verified,
    DateTime? createdAt,
    String? organizationName,
    String? registrationNumber,
    String? licenseNumber,
    String? clinicName,
    bool? availability,
    String? transport,
    String? areaOfOperation,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      city: city ?? this.city,
      location: location ?? this.location,
      verified: verified ?? this.verified,
      createdAt: createdAt ?? this.createdAt,
      organizationName: organizationName ?? this.organizationName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      clinicName: clinicName ?? this.clinicName,
      availability: availability ?? this.availability,
      transport: transport ?? this.transport,
      areaOfOperation: areaOfOperation ?? this.areaOfOperation,
    );
  }
}

/// Animal Report model
class AnimalReport {
  final String reportId;
  final String reportedBy;
  final AnimalType animalType;
  final AnimalCondition condition;
  final EmergencyLevel emergencyLevel;
  final String description;
  final String? imageRef; // Firebase Storage reference
  final GeoPoint location;
  final String address;
  final ReportStatus status;
  final String? assignedVolunteer;
  final String? assignedNGO;
  final String? assignedVet;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AnimalReport({
    required this.reportId,
    required this.reportedBy,
    required this.animalType,
    required this.condition,
    required this.emergencyLevel,
    required this.description,
    this.imageRef,
    required this.location,
    required this.address,
    this.status = ReportStatus.reported,
    this.assignedVolunteer,
    this.assignedNGO,
    this.assignedVet,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'reportId': reportId,
      'reportedBy': reportedBy,
      'animalType': animalType.value,
      'condition': condition.value,
      'emergencyLevel': emergencyLevel.value,
      'description': description,
      'imageRef': imageRef,
      'location': location,
      'address': address,
      'status': status.value,
      'assignedVolunteer': assignedVolunteer,
      'assignedNGO': assignedNGO,
      'assignedVet': assignedVet,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory AnimalReport.fromFirestore(Map<String, dynamic> data) {
    return AnimalReport(
      reportId: data['reportId'] as String,
      reportedBy: data['reportedBy'] as String,
      animalType: AnimalType.fromString(data['animalType'] as String),
      condition: AnimalCondition.fromString(data['condition'] as String),
      emergencyLevel: EmergencyLevel.fromString(data['emergencyLevel'] as String),
      description: data['description'] as String,
      imageRef: data['imageRef'] as String?,
      location: data['location'] as GeoPoint,
      address: data['address'] as String,
      status: ReportStatus.fromString(data['status'] as String),
      assignedVolunteer: data['assignedVolunteer'] as String?,
      assignedNGO: data['assignedNGO'] as String?,
      assignedVet: data['assignedVet'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  AnimalReport copyWith({
    String? reportId,
    String? reportedBy,
    AnimalType? animalType,
    AnimalCondition? condition,
    EmergencyLevel? emergencyLevel,
    String? description,
    String? imageRef,
    GeoPoint? location,
    String? address,
    ReportStatus? status,
    String? assignedVolunteer,
    String? assignedNGO,
    String? assignedVet,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnimalReport(
      reportId: reportId ?? this.reportId,
      reportedBy: reportedBy ?? this.reportedBy,
      animalType: animalType ?? this.animalType,
      condition: condition ?? this.condition,
      emergencyLevel: emergencyLevel ?? this.emergencyLevel,
      description: description ?? this.description,
      imageRef: imageRef ?? this.imageRef,
      location: location ?? this.location,
      address: address ?? this.address,
      status: status ?? this.status,
      assignedVolunteer: assignedVolunteer ?? this.assignedVolunteer,
      assignedNGO: assignedNGO ?? this.assignedNGO,
      assignedVet: assignedVet ?? this.assignedVet,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Rescue Log model for tracking timeline
class RescueLog {
  final String logId;
  final String reportId;
  final String action;
  final String performedBy;
  final DateTime timestamp;
  final String? notes;

  RescueLog({
    required this.logId,
    required this.reportId,
    required this.action,
    required this.performedBy,
    required this.timestamp,
    this.notes,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'logId': logId,
      'reportId': reportId,
      'action': action,
      'performedBy': performedBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
    };
  }

  factory RescueLog.fromFirestore(Map<String, dynamic> data) {
    return RescueLog(
      logId: data['logId'] as String,
      reportId: data['reportId'] as String,
      action: data['action'] as String,
      performedBy: data['performedBy'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
    );
  }
}

/// Medical Record model
class MedicalRecord {
  final String recordId;
  final String reportId;
  final String vetId;
  final String diagnosis;
  final String treatment;
  final bool vaccinated;
  final bool sterilized;
  final DateTime? followUpDate;
  final String status;
  final List<String> medications;
  final DateTime createdAt;

  MedicalRecord({
    required this.recordId,
    required this.reportId,
    required this.vetId,
    required this.diagnosis,
    required this.treatment,
    this.vaccinated = false,
    this.sterilized = false,
    this.followUpDate,
    required this.status,
    this.medications = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'recordId': recordId,
      'reportId': reportId,
      'vetId': vetId,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'vaccinated': vaccinated,
      'sterilized': sterilized,
      'followUpDate': followUpDate != null ? Timestamp.fromDate(followUpDate!) : null,
      'status': status,
      'medications': medications,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MedicalRecord.fromFirestore(Map<String, dynamic> data) {
    return MedicalRecord(
      recordId: data['recordId'] as String,
      reportId: data['reportId'] as String,
      vetId: data['vetId'] as String,
      diagnosis: data['diagnosis'] as String,
      treatment: data['treatment'] as String,
      vaccinated: data['vaccinated'] as bool? ?? false,
      sterilized: data['sterilized'] as bool? ?? false,
      followUpDate: data['followUpDate'] != null 
          ? (data['followUpDate'] as Timestamp).toDate() 
          : null,
      status: data['status'] as String,
      medications: List<String>.from(data['medications'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
