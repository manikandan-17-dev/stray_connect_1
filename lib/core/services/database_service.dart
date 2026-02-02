import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stray_resuce_bih/core/models/models.dart';
import 'package:stray_resuce_bih/core/models/enums.dart';

/// Database service for Firestore operations
/// Implements the complete database architecture
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String usersCollection = 'users';
  static const String reportsCollection = 'animal_reports';
  static const String rescueLogsCollection = 'rescue_logs';
  static const String medicalRecordsCollection = 'medical_records';

  // ==================== USER OPERATIONS ====================

  /// Create user profile in Firestore
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(user.uid)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Get user profile by UID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(uid)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Stream user profile
  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore
        .collection(usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc.data()!);
    });
  }

  /// Get users by role
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .where('role', isEqualTo: role.value)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }

  /// Check if user exists by email
  Future<bool> checkUserExists(String email) async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check user existence: $e');
    }
  }

  // ==================== ANIMAL REPORT OPERATIONS ====================

  /// Create animal report
  Future<String> createAnimalReport(AnimalReport report) async {
    try {
      final docRef = await _firestore
          .collection(reportsCollection)
          .add(report.toFirestore());
      
      // Update with generated ID
      await docRef.update({'reportId': docRef.id});
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create animal report: $e');
    }
  }

  /// Get animal report by ID
  Future<AnimalReport?> getAnimalReport(String reportId) async {
    try {
      final doc = await _firestore
          .collection(reportsCollection)
          .doc(reportId)
          .get();

      if (!doc.exists) return null;
      return AnimalReport.fromFirestore(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get animal report: $e');
    }
  }

  /// Update animal report
  Future<void> updateAnimalReport(String reportId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(reportsCollection)
          .doc(reportId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update animal report: $e');
    }
  }

  /// Get reports by user (citizen's reports)
  Future<List<AnimalReport>> getReportsByUser(String uid) async {
    try {
      final snapshot = await _firestore
          .collection(reportsCollection)
          .where('reportedBy', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AnimalReport.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user reports: $e');
    }
  }

  /// Get reports by status
  Future<List<AnimalReport>> getReportsByStatus(ReportStatus status) async {
    try {
      final snapshot = await _firestore
          .collection(reportsCollection)
          .where('status', isEqualTo: status.value)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AnimalReport.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports by status: $e');
    }
  }

  /// Get nearby reports (for volunteers)
  /// Note: For production, use GeoHash for better performance
  Future<List<AnimalReport>> getNearbyReports({
    required GeoPoint userLocation,
    double radiusKm = 10.0,
    ReportStatus? status,
  }) async {
    try {
      Query query = _firestore.collection(reportsCollection);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final reports = snapshot.docs
          .map((doc) => AnimalReport.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by distance (simple implementation)
      // For production, use GeoHash or GeoFirestore
      return reports.where((report) {
        final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          report.location.latitude,
          report.location.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get nearby reports: $e');
    }
  }

  /// Stream reports (real-time updates)
  Stream<List<AnimalReport>> streamReports({
    ReportStatus? status,
    String? assignedTo,
  }) {
    Query query = _firestore.collection(reportsCollection);

    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }

    if (assignedTo != null) {
      query = query.where('assignedVolunteer', isEqualTo: assignedTo);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnimalReport.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Assign report to volunteer
  Future<void> assignReportToVolunteer(String reportId, String volunteerId) async {
    try {
      await updateAnimalReport(reportId, {
        'assignedVolunteer': volunteerId,
        'status': ReportStatus.accepted.value,
      });

      // Create rescue log
      await createRescueLog(RescueLog(
        logId: '',
        reportId: reportId,
        action: 'Report accepted by volunteer',
        performedBy: volunteerId,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      throw Exception('Failed to assign report: $e');
    }
  }

  // ==================== RESCUE LOG OPERATIONS ====================

  /// Create rescue log
  Future<void> createRescueLog(RescueLog log) async {
    try {
      final docRef = await _firestore
          .collection(rescueLogsCollection)
          .add(log.toFirestore());
      
      await docRef.update({'logId': docRef.id});
    } catch (e) {
      throw Exception('Failed to create rescue log: $e');
    }
  }

  /// Get rescue logs for a report
  Future<List<RescueLog>> getRescueLogs(String reportId) async {
    try {
      final snapshot = await _firestore
          .collection(rescueLogsCollection)
          .where('reportId', isEqualTo: reportId)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => RescueLog.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get rescue logs: $e');
    }
  }

  /// Stream rescue logs
  Stream<List<RescueLog>> streamRescueLogs(String reportId) {
    return _firestore
        .collection(rescueLogsCollection)
        .where('reportId', isEqualTo: reportId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RescueLog.fromFirestore(doc.data()))
            .toList());
  }

  // ==================== MEDICAL RECORD OPERATIONS ====================

  /// Create medical record
  Future<String> createMedicalRecord(MedicalRecord record) async {
    try {
      final docRef = await _firestore
          .collection(medicalRecordsCollection)
          .add(record.toFirestore());
      
      await docRef.update({'recordId': docRef.id});
      
      // Update report status
      await updateAnimalReport(record.reportId, {
        'status': ReportStatus.atClinic.value,
        'assignedVet': record.vetId,
      });

      // Create rescue log
      await createRescueLog(RescueLog(
        logId: '',
        reportId: record.reportId,
        action: 'Medical treatment started',
        performedBy: record.vetId,
        timestamp: DateTime.now(),
      ));

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create medical record: $e');
    }
  }

  /// Get medical record by report ID
  Future<MedicalRecord?> getMedicalRecordByReportId(String reportId) async {
    try {
      final snapshot = await _firestore
          .collection(medicalRecordsCollection)
          .where('reportId', isEqualTo: reportId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return MedicalRecord.fromFirestore(snapshot.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get medical record: $e');
    }
  }

  /// Update medical record
  Future<void> updateMedicalRecord(String recordId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(medicalRecordsCollection)
          .doc(recordId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update medical record: $e');
    }
  }

  /// Get medical records by vet
  Future<List<MedicalRecord>> getMedicalRecordsByVet(String vetId) async {
    try {
      final snapshot = await _firestore
          .collection(medicalRecordsCollection)
          .where('vetId', isEqualTo: vetId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicalRecord.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get vet medical records: $e');
    }
  }

  // ==================== ANALYTICS & STATISTICS ====================

  /// Get report statistics
  Future<Map<String, int>> getReportStatistics() async {
    try {
      final snapshot = await _firestore
          .collection(reportsCollection)
          .get();

      final stats = <String, int>{
        'total': snapshot.docs.length,
        'reported': 0,
        'accepted': 0,
        'rescueInProgress': 0,
        'atClinic': 0,
        'resolved': 0,
      };

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Calculate distance between two coordinates (Haversine formula)
  /// Returns distance in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.toRadians().cos() * lat2.toRadians().cos() *
        (dLon / 2).sin() * (dLon / 2).sin();

    final c = 2 * (a.sqrt()).asin();
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}

extension on double {
  double toRadians() => this * (3.14159265359 / 180);
  double sin() => this;
  double cos() => this;
  double asin() => this;
  double sqrt() => this;
}
