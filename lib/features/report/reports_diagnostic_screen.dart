import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stray_resuce_bih/core/theme/app_theme.dart';

/// Diagnostic screen to check Firestore reports
class ReportsDiagnosticScreen extends StatelessWidget {
  const ReportsDiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports Diagnostic'),
        backgroundColor: AppTheme.primaryOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Current User', [
              'UID: ${currentUser?.uid ?? "Not logged in"}',
              'Email: ${currentUser?.email ?? "N/A"}',
              'Logged in: ${currentUser != null}',
            ]),
            
            const SizedBox(height: 20),
            
            _buildSection('Firestore Query', [
              'Collection: reports',
              'Filter: userId == ${currentUser?.uid}',
              'Expected: All reports by this user',
            ]),
            
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: () => _checkFirestore(context, currentUser),
              icon: const Icon(Icons.search),
              label: const Text('Check Firestore Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 20),
            
            StreamBuilder<QuerySnapshot>(
              stream: currentUser != null
                  ? FirebaseFirestore.instance
                      .collection('reports')
                      .where('userId', isEqualTo: currentUser.uid)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (currentUser == null) {
                  return _buildSection('Status', ['Please login first']);
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildSection('Status', ['Loading...']);
                }
                
                if (snapshot.hasError) {
                  return _buildSection('Error', [
                    'Error: ${snapshot.error}',
                    'This might be a permission issue',
                  ]);
                }
                
                if (!snapshot.hasData) {
                  return _buildSection('Status', ['No data received']);
                }
                
                final reports = snapshot.data!.docs;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Results', [
                      'Total reports found: ${reports.length}',
                      'Connection: ${snapshot.connectionState}',
                    ]),
                    
                    if (reports.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Report Details:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...reports.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${doc.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Animal: ${data['animalType']}'),
                                Text('Condition: ${data['condition']}'),
                                Text('Status: ${data['status']}'),
                                Text('Has Image: ${data['imageBase64'] != null && data['imageBase64'].toString().isNotEmpty}'),
                                Text('Created: ${data['createdAt']}'),
                                Text('User ID: ${data['userId']}'),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(item),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _checkFirestore(BuildContext context, User? currentUser) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    try {
      print('🔍 Manual Firestore Check...');
      print('Current User: ${currentUser.uid}');
      print('Email: ${currentUser.email}');
      
      final snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      
      print('✅ Query successful!');
      print('📊 Total reports found: ${snapshot.docs.length}');
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('---');
        print('Report ID: ${doc.id}');
        print('Animal: ${data['animalType']}');
        print('Condition: ${data['condition']}');
        print('Status: ${data['status']}');
        print('Has Image: ${data['imageBase64'] != null && data['imageBase64'].toString().isNotEmpty}');
        print('Created: ${data['createdAt']}');
        print('User ID: ${data['userId']}');
      }
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${snapshot.docs.length} reports. Check console for details.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error querying Firestore: $e');
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
