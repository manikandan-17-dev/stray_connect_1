import 'package:flutter/material.dart';
import 'package:stray_resuce_bih/core/theme/app_theme.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stray_resuce_bih/features/report/reports_diagnostic_screen.dart';
import 'package:stray_resuce_bih/features/report/userid_debug_screen.dart';
import 'package:stray_resuce_bih/features/report/manual_reports_fetch_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Reports'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
        ),
        body: const Center(
          child: Text('Please login to view your reports'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Reports',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          // Debug button to check Firestore
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              print('🔍 Manual Firestore Check...');
              print('Current User: ${currentUser.uid}');
              print('Email: ${currentUser.email}');
              
              try {
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
                }
                
                if (snapshot.docs.isEmpty) {
                  print('⚠️ No reports found for this user');
                  print('💡 Try submitting a new report first');
                }
              } catch (e) {
                print('❌ Error querying Firestore: $e');
              }
            },
            tooltip: 'Refresh & Debug',
          ),
          // User ID Debug button
          IconButton(
            icon: const Icon(Icons.person_search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserIdDebugScreen(),
                ),
              );
            },
            tooltip: 'Check User ID',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('userId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          final reports = snapshot.data!.docs;
          
          // Sort locally if needed or rely on Firestore order if index exists
          // Sorting by timestamp descending (newest first)
          reports.sort((a, b) {
             final aTime = (a.data() as Map)['createdAt'] ?? '';
             final bTime = (b.data() as Map)['createdAt'] ?? '';
             return bTime.compareTo(aTime); 
          });

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Taller cards for image + text
            ),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final reportData = reports[index].data() as Map<String, dynamic>;
              return _buildGridReportCard(context, reportData);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Keep debug functionality accessible
           Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserIdDebugScreen()),
          );
        },
        child: const Icon(Icons.bug_report),
        tooltip: 'Debug Reports',
      ),
    );
  }

  Widget _buildGridReportCard(BuildContext context, Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Image Section (Expanded to fill available space)
          Expanded(
            child: _buildBase64Image(data['imageBase64']),
          ),
          
          // 2. Details Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (data['animalType'] ?? 'Unknown').toString().toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data['condition'] ?? 'No Condition',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                 // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(data['status']),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (data['status'] ?? 'Pending').toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No reports yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your submitted reports will appear here',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          // Debug info
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                const Text('Debug Info', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('User ID: ${FirebaseAuth.instance.currentUser?.uid ?? "Not logged in"}', 
                  style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Use the refresh icon in top bar to test connection', style: TextStyle(fontSize: 10, color: Colors.grey)),
                 const SizedBox(height: 8),
                OutlinedButton(
                   onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualReportsFetchScreen())),
                   child: const Text('Try Manual Fetch Tool'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'recovered':
        return Colors.green;
      case 'critical':
        return Colors.red;
      case 'treating':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
  Widget _buildReportCard(BuildContext context, Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showReportDetails(context, report),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (report['imageBase64'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: _buildBase64Image(report['imageBase64']),
              ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animal Type & Status
                  Row(
                    children: [
                      _buildAnimalTypeChip(report['animalType']),
                      const SizedBox(width: 8),
                      _buildStatusChip(report['status']),
                      const Spacer(),
                      _buildEmergencyBadge(report['emergencyLevel']),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Condition
                  Text(
                    _getConditionText(report['condition']),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  if (report['description'] != null && report['description'].isNotEmpty)
                    Text(
                      report['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),

                  // Timestamp & Location
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(report['timestamp']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Erode, TN',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Decode and display base64 image
  Widget _buildBase64Image(String? base64String) {
    // Handle null or empty base64 string
    if (base64String == null || base64String.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'No image available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    try {
      // Decode base64 string to bytes
      final Uint8List bytes = base64Decode(base64String);
      
      return Image.memory(
        bytes,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error displaying image: $error');
          return Container(
            height: 200,
            color: Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 50, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error decoding base64 image: $e');
      return Container(
        height: 200,
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.red.shade300),
            const SizedBox(height: 8),
            Text(
              'Invalid image data',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAnimalTypeChip(String type) {
    final icons = {
      'dog': '🐕',
      'cat': '🐈',
      'cow': '🐄',
      'bird': '🐦',
      'other': '🦮',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icons[type] ?? '🐾', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            type.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final colors = {
      'pending': Colors.orange,
      'in_progress': Colors.blue,
      'resolved': AppTheme.accentGreen,
    };

    final labels = {
      'pending': 'Pending',
      'in_progress': 'In Progress',
      'resolved': 'Resolved',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (colors[status] ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors[status] ?? Colors.grey, width: 1.5),
      ),
      child: Text(
        labels[status] ?? status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colors[status] ?? Colors.grey,
        ),
      ),
    );
  }

  Widget _buildEmergencyBadge(double level) {
    Color color;
    String text;

    if (level >= 2.5) {
      color = AppTheme.warningRed;
      text = 'CRITICAL';
    } else if (level >= 1.5) {
      color = AppTheme.warningOrange;
      text = 'MEDIUM';
    } else {
      color = AppTheme.accentGreen;
      text = 'LOW';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getConditionText(String condition) {
    final conditions = {
      'injured': '🤕 Injured Animal',
      'sick': '🤒 Sick Animal',
      'accident': '🚗 Accident Victim',
      'aggressive': '😠 Aggressive Behavior',
      'pregnant': '🤰 Pregnant Animal',
      'newborn': '👶 Newborn Animal',
    };
    return conditions[condition] ?? condition;
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      DateTime dateTime;
      
      // Handle Firestore Timestamp
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } 
      // Handle ISO string
      else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } 
      // Handle null or unknown
      else {
        return 'Unknown';
      }
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Report Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),

              // Image
              if (report['imageBase64'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildBase64Image(report['imageBase64']),
                ),
              const SizedBox(height: 20),

              // Details
              _buildDetailRow('Animal Type', _getAnimalTypeText(report['animalType'])),
              _buildDetailRow('Condition', _getConditionText(report['condition'])),
              _buildDetailRow('Emergency Level', _getEmergencyText(report['emergencyLevel'])),
              _buildDetailRow('Status', report['status']),
              _buildDetailRow('Reported', _formatTimestamp(report['timestamp'])),
              
              if (report['description'] != null && report['description'].isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report['description'],
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAnimalTypeText(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }

  String _getEmergencyText(double level) {
    if (level >= 2.5) return 'Critical 🚨';
    if (level >= 1.5) return 'Medium ⚠️';
    return 'Low ✅';
  }
}
