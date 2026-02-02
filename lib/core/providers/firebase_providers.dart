import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stray_resuce_bih/core/services/firebase_service.dart';

/// Provider for Firebase Service
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Provider for current user
final currentUserProvider = StreamProvider<User?>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.authStateChanges;
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for user profile stream
final userProfileProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, userId) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.streamUserProfile(userId).map((snapshot) {
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>?;
    }
    return null;
  });
});
