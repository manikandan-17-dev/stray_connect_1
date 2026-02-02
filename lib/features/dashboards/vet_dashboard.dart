import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stray_resuce_bih/core/theme/app_theme.dart';
import 'package:stray_resuce_bih/core/services/firebase_service.dart';
import 'package:stray_resuce_bih/features/auth/screens/welcome_screen.dart';
import 'package:stray_resuce_bih/features/report/my_reports_screen.dart';
import 'package:stray_resuce_bih/features/profile/profile_screen.dart';
import 'package:stray_resuce_bih/features/notifications/notifications_screen.dart';

/// Vet Dashboard
class VetDashboard extends ConsumerStatefulWidget {
  const VetDashboard({super.key});

  @override
  ConsumerState<VetDashboard> createState() => _VetDashboardState();
}

class _VetDashboardState extends ConsumerState<VetDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _VetCasesPlaceholder(), 
    MyReportsScreen(), // Or specific Vet cases screen if it existed
    NotificationsScreen(),
    ProfileScreen(),
  ];

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await FirebaseService().signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏥 Vet Dashboard'),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Cases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _VetCasesPlaceholder extends StatelessWidget {
  const _VetCasesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.medical_services, size: 100, color: AppTheme.primaryOrange),
          const SizedBox(height: 24),
          const Text(
            'Active Cases',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Incoming animal rescue cases requiring medical attention will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
