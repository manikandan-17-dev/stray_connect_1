import 'package:flutter/material.dart';
import 'package:stray_resuce_bih/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:http/http.dart' as http;

class ImprovedReportCreateScreen extends StatefulWidget {
  const ImprovedReportCreateScreen({super.key});

  @override
  State<ImprovedReportCreateScreen> createState() => _ImprovedReportCreateScreenState();
}

class _ImprovedReportCreateScreenState extends State<ImprovedReportCreateScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _animalType;
  String? _condition;
  double _emergencyLevel = 2; // 1=low, 2=medium, 3=critical
  final _descriptionCtrl = TextEditingController();
  bool _hasPhoto = false;
  bool _hasLocation = false; // Changed to false: User must tap to detect
  
  // Image capture variables
  File? _capturedImage;
  String? _imageBase64;
  final ImagePicker _picker = ImagePicker();
  
  // Location variables
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLocating = false;
  bool _isSubmitting = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double get _completionProgress {
    int completed = 0;
    if (_hasPhoto) completed++;
    if (_animalType != null) completed++;
    if (_condition != null) completed++;
    if (_hasLocation) completed++;
    return completed / 4;
  }

  bool get _canSubmit => _completionProgress == 1.0;
  
  Future<void> _capturePhoto() async {
    try {
      // Open camera to capture photo
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress to reduce size
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (photo == null) return; // User cancelled
      
      // Read image file
      final File imageFile = File(photo.path);
      final bytes = await imageFile.readAsBytes();
      
      // Convert to base64
      final base64String = base64Encode(bytes);
      
      setState(() {
        _capturedImage = imageFile;
        _imageBase64 = base64String;
        _hasPhoto = true;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Photo captured successfully!'),
            backgroundColor: AppTheme.accentGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to capture photo: $e'),
            backgroundColor: AppTheme.warningRed,
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse Geocoding with OSM Nominatim
      String address = 'Fetching address...';
      try {
        // Using Nominatim API for detailed POI data (e.g. College names)
        final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1');
        final response = await http.get(url, headers: {'User-Agent': 'com.example.stray_rescue_bih'});
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['address'] != null) {
             final a = data['address'];
             List<String> parts = [];
             
             // 1. POI Name (The most important part!)
             if (a['amenity'] != null) parts.add(a['amenity']);
             else if (a['building'] != null) parts.add(a['building']);
             else if (a['institution'] != null) parts.add(a['institution']);
             else if (a['university'] != null) parts.add(a['university']);
             
             // 2. Street/Area
             if (a['road'] != null) parts.add(a['road']);
             if (a['suburb'] != null) parts.add(a['suburb']);
             else if (a['neighbourhood'] != null) parts.add(a['neighbourhood']);
             
             // 3. City
             if (a['city'] != null) parts.add(a['city']);
             else if (a['town'] != null) parts.add(a['town']);
             
             // 4. Pincode
             if (a['postcode'] != null) parts.add(a['postcode']);
             
             // User requested FULL DETAIL, so we prioritize the complete display_name
             // derived by OSM which includes everything.
             if (data['display_name'] != null) {
               address = data['display_name'];
             } else {
               address = parts.join(', ');
             }
          }
        } else {
             // Fallback to local geocoder if API fails
             throw Exception('API failed'); 
        }
      } catch (e) {
        print('OSM Error: $e, falling back to local geocoder');
        try {
          final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            address = [p.name, p.street, p.subLocality, p.locality, p.postalCode]
              .where((e) => e != null && e.isNotEmpty).toSet().join(', ');
          }
        } catch (_) {
           address = 'Location found (Address unavailable)';
        }
      }

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _currentAddress = address;
          _hasLocation = true;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _submit() async {
    print('🔵 Submit button clicked');
    
    // Check if all required fields are complete
    if (!_canSubmit) {
      print('❌ Cannot submit - missing required fields');
      print('   Photo: $_hasPhoto');
      print('   Animal Type: $_animalType');
      print('   Condition: $_condition');
      print('   Location: $_hasLocation');
      _showErrorSnackBar('Please complete all required fields');
      return;
    }
    
    // Get current user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('❌ No user logged in');
      _showErrorSnackBar('Please login to submit a report');
      return;
    }

    print('✅ User authenticated: ${currentUser.email}');
    print('📊 Report data: Animal=$_animalType, Condition=$_condition, Emergency=$_emergencyLevel');
    print('📸 Image: ${_imageBase64 != null ? "Yes (${_imageBase64!.length} chars)" : "No"}');

    setState(() => _isSubmitting = true);

    try {
      print('🌍 Getting location...');
      // Get current location
      await _getCurrentLocation();
      print('📍 Location: ${_currentPosition != null ? "GPS" : "Default"}');

      // Prepare report data
      final reportData = {
        'userId': currentUser.uid,
        'userEmail': currentUser.email ?? 'unknown',
        'animalType': _animalType ?? 'unknown',
        'condition': _condition ?? 'unknown',
        'emergencyLevel': _emergencyLevel,
        'description': _descriptionCtrl.text.trim(),
        'imageBase64': _imageBase64 ?? '', // Base64 encoded image
        'location': _currentPosition != null
            ? GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude)
            : const GeoPoint(11.3410, 77.7172), // Default to Erode
        'locationName': 'Erode, Tamil Nadu',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      print('💾 Saving to Firestore...');
      // Save to Firestore
      await FirebaseFirestore.instance.collection('reports').add(reportData);
      print('✅ Report saved successfully!');

      if (!mounted) return;
      
      setState(() => _isSubmitting = false);

      // Show success animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _SuccessDialog(),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop(); // Close dialog
          // Reset form
          setState(() {
            _animalType = null;
            _condition = null;
            _emergencyLevel = 2;
            _hasPhoto = false;
            _capturedImage = null;
            _imageBase64 = null;
            _descriptionCtrl.clear();
          });
          print('🔄 Form reset');
        }
      });
    } on FirebaseException catch (e) {
      print('❌ Firebase error: ${e.code} - ${e.message}');
      setState(() => _isSubmitting = false);
      
      String userMessage;
      switch (e.code) {
        case 'permission-denied':
          userMessage = 'Permission denied. Please check your account settings.';
          break;
        case 'unavailable':
          userMessage = 'Service unavailable. Please check your internet connection.';
          break;
        case 'deadline-exceeded':
          userMessage = 'Request timeout. Please try again.';
          break;
        default:
          userMessage = 'Failed to submit report. Please try again later.';
      }
      
      _showErrorSnackBar(userMessage);
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isSubmitting = false);
      
      String userMessage = 'An unexpected error occurred. Please try again.';
      
      // Check for common errors
      if (e.toString().contains('network')) {
        userMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('timeout')) {
        userMessage = 'Request timeout. Please try again.';
      }
      
      _showErrorSnackBar(userMessage);
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.warningRed,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Determine if we should show the full scaffold (standalone) or just content (embedded)
    // For now, since it's used in HomeScreen, we'll assume embedded but wrap with a specialized layout
    // to avoid the double-appbar issue.
    
    return Column(
      children: [
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 // Progress Indicator Header (Custom, not AppBar)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Report Incident',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _completionProgress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_completionProgress * 100).toInt()}% Completed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Photo Card
                _buildPhotoCard(),
                const SizedBox(height: 16),
                
                // Animal Type Card
                _buildAnimalTypeCard(),
                const SizedBox(height: 16),
                
                // Condition Card
                _buildConditionCard(),
                const SizedBox(height: 16),
                
                // Emergency Level Card
                _buildEmergencyLevelCard(),
                const SizedBox(height: 16),
                
                // Location Card
                _buildLocationCard(),
                const SizedBox(height: 16),
                
                // Description Card
                _buildDescriptionCard(),
                const SizedBox(height: 32),
                
                // Submit Button
                _buildSubmitButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard() {
    return Card(
      child: InkWell(
        onTap: _capturePhoto, // Open camera when tapped
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _hasPhoto ? Icons.check_circle : Icons.camera_alt,
                    color: _hasPhoto ? AppTheme.accentGreen : AppTheme.primaryOrange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '📸 Take Photo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (!_hasPhoto)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.warningRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Required',
                        style: TextStyle(
                          color: AppTheme.warningRed,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (!_hasPhoto) ...[
                const SizedBox(height: 12),
                Text(
                  'Take a clear photo of the animal',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 2, strokeAlign: BorderSide.strokeAlignInside),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to capture',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                // Display captured image
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentGreen, width: 2),
                  ),
                  child: _capturedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _capturedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 48, color: AppTheme.accentGreen),
                              SizedBox(height: 8),
                              Text(
                                'Photo captured ✓',
                                style: TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                // Retake button
                TextButton.icon(
                  onPressed: _capturePhoto,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retake Photo'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalTypeCard() {
    final types = [
      {'icon': '🐕', 'label': 'Dog', 'value': 'dog'},
      {'icon': '🐈', 'label': 'Cat', 'value': 'cat'},
      {'icon': '🐄', 'label': 'Cow', 'value': 'cow'},
      {'icon': '🐦', 'label': 'Bird', 'value': 'bird'},
      {'icon': '🦮', 'label': 'Other', 'value': 'other'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🐾 Animal Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: types.map((type) {
                final isSelected = _animalType == type['value'];
                return InkWell(
                  onTap: () => setState(() => _animalType = type['value'] as String),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          type['icon'] as String,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type['label'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.primaryDeep,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionCard() {
    final conditions = [
      {'emoji': '🤕', 'label': 'Injured', 'value': 'injured'},
      {'emoji': '🤒', 'label': 'Sick', 'value': 'sick'},
      {'emoji': '🚗', 'label': 'Accident', 'value': 'accident'},
      {'emoji': '😠', 'label': 'Aggressive', 'value': 'aggressive'},
      {'emoji': '🤰', 'label': 'Pregnant', 'value': 'pregnant'},
      {'emoji': '👶', 'label': 'Newborn', 'value': 'newborn'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🩺 Condition',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: conditions.map((cond) {
                final isSelected = _condition == cond['value'];
                return InkWell(
                  onTap: () => setState(() => _condition = cond['value'] as String),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cond['emoji'] as String,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cond['label'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.primaryDeep,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyLevelCard() {
    Color getSliderColor() {
      if (_emergencyLevel >= 2.5) return AppTheme.warningRed;
      if (_emergencyLevel >= 1.5) return AppTheme.warningOrange;
      return AppTheme.accentGreen;
    }

    String getEmergencyText() {
      if (_emergencyLevel >= 2.5) return 'Critical 🚨';
      if (_emergencyLevel >= 1.5) return 'Medium ⚠️';
      return 'Low ✅';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🚨 Emergency Level',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: getSliderColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: getSliderColor(), width: 2),
                  ),
                  child: Text(
                    getEmergencyText(),
                    style: TextStyle(
                      color: getSliderColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: getSliderColor(),
                inactiveTrackColor: getSliderColor().withOpacity(0.2),
                thumbColor: getSliderColor(),
                overlayColor: getSliderColor().withOpacity(0.2),
                trackHeight: 8,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              ),
              child: Slider(
                value: _emergencyLevel,
                min: 1,
                max: 3,
                divisions: 2,
                onChanged: (value) => setState(() => _emergencyLevel = value),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Low', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text('Medium', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text('Critical', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: InkWell(
        onTap: _getCurrentLocation,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on,
                color: AppTheme.accentGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasLocation ? '📍 Location Detected' : '📍 Location Required',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_isLocating)
                    const Row(
                      children: [
                        SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('Fetching detailed address...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  else ...[
                    Text(
                      _currentAddress ?? 'Tap to detect location',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _hasLocation ? Colors.black87 : Colors.grey,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_hasLocation && _currentPosition != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                              initialZoom: 17.0, // Closer zoom for satellite
                              // Interaction enabled by default!
                            ),
                            children: [
                              TileLayer(
                                // Esri World Imagery (Satellite)
                                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                                userAgentPackageName: 'com.example.stray_resuce_bih',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            if (_hasLocation) 
               const Icon(Icons.check_circle, color: AppTheme.accentGreen),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📝 Additional Details (Optional)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe what you see...',
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScaleTransition(
      scale: _canSubmit && !_isSubmitting ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: _canSubmit && !_isSubmitting ? AppTheme.primaryGradient : null,
          color: _canSubmit && !_isSubmitting ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _canSubmit && !_isSubmitting
              ? [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _canSubmit && !_isSubmitting ? _submit : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _canSubmit ? Icons.send : Icons.lock,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _canSubmit ? 'SUBMIT REPORT' : 'COMPLETE ALL FIELDS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: AppTheme.accentGreen,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '🐾 Report Submitted!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Help is on the way.\nYou just saved a life ❤️',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
