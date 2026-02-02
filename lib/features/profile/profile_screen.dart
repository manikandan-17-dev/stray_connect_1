import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stray_resuce_bih/core/storage/local_prefs.dart';
import 'package:stray_resuce_bih/features/profile/edit_profile_screen.dart';
import 'package:stray_resuce_bih/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stray_resuce_bih/features/auth/auth_gate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name;
  String? _phone;
  String? _city;
  String? _ward;
  String? _role;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Try fetching from Firestore first (Source of Truth)
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          
          // Update State
          setState(() {
            _name = data['name'];
            _phone = data['phone'];
            _city = data['city'];
            _ward = data['ward'];
            _role = data['role'];
            _isLoading = false;
          });

          // Sync back to LocalPrefs for future offline use
          await LocalPrefs.setString(LocalPrefs.keyName, _name ?? '');
          await LocalPrefs.setString(LocalPrefs.keyPhone, _phone ?? '');
          await LocalPrefs.setString(LocalPrefs.keyCity, _city ?? '');
          await LocalPrefs.setString(LocalPrefs.keyWard, _ward ?? '');
          await LocalPrefs.setString(LocalPrefs.keyRole, _role ?? 'citizen');
          return;
        }
      }

      // 2. Fallback to LocalPrefs if Firestore fails or is empty (Offline mode)
      final name = await LocalPrefs.getString(LocalPrefs.keyName);
      final phone = await LocalPrefs.getString(LocalPrefs.keyPhone);
      final city = await LocalPrefs.getString(LocalPrefs.keyCity);
      final ward = await LocalPrefs.getString(LocalPrefs.keyWard);
      final role = await LocalPrefs.getString(LocalPrefs.keyRole);

      if (mounted) {
        setState(() {
          _name = name;
          _phone = phone;
          _city = city;
          _ward = ward;
          _role = role;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
     // Reload if changes were made
    if (result == true) {
      _loadProfile();
    }
  }

  
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryOrange.withOpacity(0.2),
                    child: Text(
                      _name?.isNotEmpty == true ? _name![0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _name ?? 'Guest User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _role?.toUpperCase() ?? 'USER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileItem(Icons.phone, 'Phone', _phone ?? 'Not set'),
                    const Divider(),
                    _buildProfileItem(Icons.location_city, 'City', _city ?? 'Not set'),
                    const Divider(),
                    _buildProfileItem(Icons.map, 'Ward', _ward ?? 'Not set'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Edit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Logout Button (Text Button style for secondary action)
            TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryOrange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
