import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stray_resuce_bih/core/theme/app_theme.dart';

/// Simple debug screen to show userId mismatch
class UserIdDebugScreen extends StatelessWidget {
  const UserIdDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User ID Debug'),
        backgroundColor: AppTheme.primaryOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current User Info
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👤 CURRENT LOGGED-IN USER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      'User ID: ${currentUser?.uid ?? "NOT LOGGED IN"}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Email: ${currentUser?.email ?? "N/A"}'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (currentUser != null) {
                          Clipboard.setData(ClipboardData(text: currentUser.uid));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User ID copied!')),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy User ID'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // All Reports
            const Text(
              '📊 ALL REPORTS IN DATABASE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No reports in database'),
                    ),
                  );
                }
                
                final reports = snapshot.data!.docs;
                
                return Column(
                  children: [
                    Text(
                      'Total: ${reports.length} reports',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...reports.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final reportUserId = data['userId'] as String?;
                      final isMatch = reportUserId == currentUser?.uid;
                      
                      return Card(
                        color: isMatch ? Colors.green.shade50 : Colors.orange.shade50,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isMatch ? Icons.check_circle : Icons.warning,
                                    color: isMatch ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isMatch ? '✅ YOUR REPORT' : '❌ NOT YOUR REPORT',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isMatch ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Text('Document ID: ${doc.id}'),
                              const SizedBox(height: 4),
                              Text('Animal: ${data['animalType'] ?? "N/A"}'),
                              Text('Condition: ${data['condition'] ?? "N/A"}'),
                              Text('Status: ${data['status'] ?? "N/A"}'),
                              const SizedBox(height: 8),
                              const Text(
                                'Report User ID:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SelectableText(
                                reportUserId ?? 'NULL',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!isMatch && currentUser != null) ...[
                                const Text(
                                  '⚠️ This report belongs to a different user!',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'You need to login with the account that created this report.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
