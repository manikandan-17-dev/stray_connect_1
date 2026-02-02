import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stray_resuce_bih/core/providers/firebase_providers.dart';
import 'package:stray_resuce_bih/core/services/database_service.dart';
import 'package:stray_resuce_bih/features/auth/screens/welcome_screen.dart';
import 'package:stray_resuce_bih/features/dashboards/citizen_dashboard.dart';
import 'package:stray_resuce_bih/features/dashboards/volunteer_dashboard.dart';
import 'package:stray_resuce_bih/features/dashboards/ngo_dashboard.dart';
import 'package:stray_resuce_bih/features/dashboards/vet_dashboard.dart';
import 'package:stray_resuce_bih/core/models/enums.dart';

/// AuthGate - Handles automatic login/logout
/// Shows Welcome Screen if not logged in
/// Shows role-based dashboard if logged in
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          // Not logged in → Show Welcome Screen
          return const WelcomeScreen();
        }

        // Logged in → Fetch user profile and show dashboard
        return FutureBuilder(
          future: DatabaseService().getUserProfile(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const WelcomeScreen();
            }

            final userProfile = snapshot.data!;

            // Navigate to role-based dashboard
            switch (userProfile.role) {
              case UserRole.citizen:
                return const CitizenDashboard();
              case UserRole.volunteer:
                return const VolunteerDashboard();
              case UserRole.ngo:
                return const NGODashboard();
              case UserRole.vet:
                return const VetDashboard();
            }
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const WelcomeScreen(),
    );
  }
}
