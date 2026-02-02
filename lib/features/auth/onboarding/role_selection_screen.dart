import 'package:flutter/material.dart';
import 'package:stray_resuce_bih/core/storage/local_prefs.dart';
import 'package:stray_resuce_bih/features/auth/onboarding/profile_setup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    await LocalPrefs.setString(LocalPrefs.keyRole, role);
    // After choosing role, go to profile setup
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'citizen'),
              child: const Text('Citizen'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'volunteer'),
              child: const Text('Volunteer / NGO'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'vet'),
              child: const Text('Veterinarian'),
            ),
          ],
        ),
      ),
    );
  }
}
