import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Simple test screen to manually fetch and display reports
class ManualReportsFetchScreen extends StatefulWidget {
  const ManualReportsFetchScreen({super.key});

  @override
  State<ManualReportsFetchScreen> createState() => _ManualReportsFetchScreenState();
}

class _ManualReportsFetchScreenState extends State<ManualReportsFetchScreen> {
  List<Map<String, dynamic>> _reports = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      print('🔵 Current User: ${currentUser?.uid}');
      print('🔵 Email: ${currentUser?.email}');

      // Fetch ALL reports first
      print('🔵 Fetching ALL reports...');
      final allSnapshot = await FirebaseFirestore.instance
          .collection('reports')
          .get();

      print('✅ Total reports in database: ${allSnapshot.docs.length}');

      // Fetch user-specific reports
      print('🔵 Fetching user-specific reports...');
      final userSnapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('userId', isEqualTo: currentUser?.uid)
          .get();

      print('✅ User-specific reports: ${userSnapshot.docs.length}');

      final reports = <Map<String, dynamic>>[];

      for (var doc in allSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['isCurrentUser'] = data['userId'] == currentUser?.uid;
        reports.add(data);

        print('---');
        print('Report ID: ${doc.id}');
        print('Animal: ${data['animalType']}');
        print('UserId: ${data['userId']}');
        print('Matches current user: ${data['isCurrentUser']}');
      }

      setState(() {
        _reports = reports;
        _loading = false;
      });
    } catch (e, stackTrace) {
      print('❌ Error fetching reports: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Reports Fetch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReports,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchReports,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '👤 Current User',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Email: ${currentUser?.email}'),
                            SelectableText(
                              'UID: ${currentUser?.uid}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total Reports: ${_reports.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._reports.map((report) {
                      final isCurrentUser = report['isCurrentUser'] as bool;
                      return Card(
                        color: isCurrentUser
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isCurrentUser
                                        ? Icons.check_circle
                                        : Icons.warning,
                                    color: isCurrentUser
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isCurrentUser
                                          ? '✅ YOUR REPORT'
                                          : '❌ OTHER USER',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isCurrentUser
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Text('ID: ${report['id']}'),
                              Text('Animal: ${report['animalType']}'),
                              Text('Condition: ${report['condition']}'),
                              Text('Status: ${report['status']}'),
                              const SizedBox(height: 8),
                              const Text(
                                'Report UserId:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SelectableText(
                                report['userId'] ?? 'null',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
    );
  }
}
