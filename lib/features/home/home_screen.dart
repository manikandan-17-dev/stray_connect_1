import 'package:flutter/material.dart';
import 'package:stray_resuce_bih/core/storage/local_prefs.dart';
import 'package:stray_resuce_bih/features/auth/onboarding/role_selection_screen.dart';
import 'package:stray_resuce_bih/features/auth/firebase_test_screen.dart';
import 'package:stray_resuce_bih/features/notifications/notifications_screen.dart';
import 'package:stray_resuce_bih/features/profile/profile_screen.dart';
import 'package:stray_resuce_bih/features/report/my_reports_screen.dart';
import 'package:stray_resuce_bih/features/report/improved_report_create_screen.dart';
import 'package:stray_resuce_bih/features/report/report_create_screen.dart';
import 'package:stray_resuce_bih/features/vet/vet_intake_screen.dart';
import 'package:stray_resuce_bih/features/volunteer/volunteer_feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _role;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final r = await LocalPrefs.getString(LocalPrefs.keyRole);
    setState(() => _role = r ?? 'citizen');
  }

  List<Widget> _citizenTabs() => const [
        ImprovedReportCreateScreen(),
        MyReportsScreen(),
        NotificationsScreen(),
        ProfileScreen(),
      ];

  List<BottomNavigationBarItem> _citizenItems() => const [
        BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
        BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'My Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];

  List<Widget> _volunteerTabs() => const [
        VolunteerFeedScreen(),
        MyReportsScreen(),
        NotificationsScreen(),
        ProfileScreen(),
      ];

  List<BottomNavigationBarItem> _volunteerItems() => const [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Feed'),
        BottomNavigationBarItem(icon: Icon(Icons.checklist_rtl), label: 'Rescues'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];

  List<Widget> _vetTabs() => const [
        VetIntakeScreen(),
        MyReportsScreen(),
        NotificationsScreen(),
        ProfileScreen(),
      ];

  List<BottomNavigationBarItem> _vetItems() => const [
        BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Intake'),
        BottomNavigationBarItem(icon: Icon(Icons.medical_information), label: 'Cases'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];

  @override
  Widget build(BuildContext context) {
    final role = _role;
    final isCitizen = role == 'citizen';
    final isVolunteer = role == 'volunteer';
    final isVet = role == 'vet';

    final widgets = isCitizen
        ? _citizenTabs()
        : isVolunteer
            ? _volunteerTabs()
            : _vetTabs();
    final items = isCitizen
        ? _citizenItems()
        : isVolunteer
            ? _volunteerItems()
            : _vetItems();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.pets, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'StrayCare',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  role ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Test Firebase',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FirebaseTestScreen()),
              );
            },
            icon: const Icon(Icons.cloud_done),
          ),
          IconButton(
            tooltip: 'Change role',
            onPressed: () async {
              await LocalPrefs.setBool(LocalPrefs.keyProfileCompleted, false);
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              );
            },
            icon: const Icon(Icons.switch_account),
          )
        ],
      ),
      body: Column(
        children: [
          // Live Stats Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  '🐾 126 animals rescued this month in Erode',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: widgets[_index]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: items,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
