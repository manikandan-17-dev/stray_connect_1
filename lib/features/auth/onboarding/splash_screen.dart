import 'package:flutter/material.dart';
import 'package:stray_resuce_bih/core/storage/local_prefs.dart';
import 'package:stray_resuce_bih/features/auth/onboarding/role_selection_screen.dart';
import 'package:stray_resuce_bih/features/auth/onboarding/profile_setup_screen.dart';
import 'package:stray_resuce_bih/features/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_decideNext);
  }

  Future<void> _decideNext() async {
    final role = await LocalPrefs.getString(LocalPrefs.keyRole);
    final completed = await LocalPrefs.getBool(LocalPrefs.keyProfileCompleted) ?? false;
    if (!mounted) return;
    if (role == null || role.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
      return;
    }
    if (!completed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
