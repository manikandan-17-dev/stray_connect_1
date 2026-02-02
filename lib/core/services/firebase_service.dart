import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class to handle Firebase operations
/// This provides a centralized way to interact with Firebase services
class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters for Firebase instances
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== Authentication Methods ====================

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Register with email and password
  Future<UserCredential?> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  // ==================== Firestore Methods ====================

  /// Create or update a document
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(
            data,
            SetOptions(merge: merge),
          );
    } catch (e) {
      throw Exception('Failed to set document: $e');
    }
  }

  /// Get a document
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  /// Delete a document
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  /// Get a collection stream
  Stream<QuerySnapshot> getCollectionStream({
    required String collection,
    Query Function(CollectionReference)? queryBuilder,
  }) {
    try {
      CollectionReference collectionRef = _firestore.collection(collection);
      if (queryBuilder != null) {
        return queryBuilder(collectionRef).snapshots();
      }
      return collectionRef.snapshots();
    } catch (e) {
      throw Exception('Failed to get collection stream: $e');
    }
  }

  /// Get a collection
  Future<QuerySnapshot> getCollection({
    required String collection,
    Query Function(CollectionReference)? queryBuilder,
  }) async {
    try {
      CollectionReference collectionRef = _firestore.collection(collection);
      if (queryBuilder != null) {
        return await queryBuilder(collectionRef).get();
      }
      return await collectionRef.get();
    } catch (e) {
      throw Exception('Failed to get collection: $e');
    }
  }

  /// Add a document to a collection
  Future<DocumentReference> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Failed to add document: $e');
    }
  }

  /// Update a document
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  /// Batch write operations
  Future<void> batchWrite(
    Future<void> Function(WriteBatch batch) operations,
  ) async {
    try {
      WriteBatch batch = _firestore.batch();
      await operations(batch);
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to perform batch write: $e');
    }
  }

  // ==================== User Profile Methods ====================

  /// Create user profile in Firestore
  Future<void> createUserProfile({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await setDocument(
        collection: 'users',
        documentId: userId,
        data: {
          ...userData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await getDocument(
        collection: 'users',
        documentId: userId,
      );
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await updateDocument(
        collection: 'users',
        documentId: userId,
        data: {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Stream user profile
  Stream<DocumentSnapshot> streamUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }
}
