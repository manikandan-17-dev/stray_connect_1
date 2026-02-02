import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stray_resuce_bih/core/storage/local_prefs.dart';
import 'package:stray_resuce_bih/core/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _wardCtrl = TextEditingController();
  
  // Location
  GeoPoint? _currentLocation;
  String _locationText = 'No location set';
  bool _isLocationUpdating = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Try to get from Firestore first for most up-to-date data
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _nameCtrl.text = data['name'] ?? '';
          _phoneCtrl.text = data['phone'] ?? '';
          _cityCtrl.text = data['city'] ?? '';
          _wardCtrl.text = data['ward'] ?? '';
          
          if (data['location'] is GeoPoint) {
            _currentLocation = data['location'];
            _locationText = '${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}';
          }
        } else {
          // Fallback to LocalPrefs
          _nameCtrl.text = await LocalPrefs.getString(LocalPrefs.keyName) ?? '';
          _phoneCtrl.text = await LocalPrefs.getString(LocalPrefs.keyPhone) ?? '';
          _cityCtrl.text = await LocalPrefs.getString(LocalPrefs.keyCity) ?? '';
          _wardCtrl.text = await LocalPrefs.getString(LocalPrefs.keyWard) ?? '';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLocation() async {
    setState(() => _isLocationUpdating = true);
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      }

      // Get location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Reverse Geocoding
      String completeAddress = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      String fetchedCity = '';
      String fetchedWard = '';

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          fetchedCity = place.locality ?? place.subAdministrativeArea ?? '';
          fetchedWard = place.subLocality ?? '';
          
          // Construct a readable address
          completeAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode
          ].where((e) => e != null && e.isNotEmpty).toSet().join(', '); // toSet to remove duplicates
        }
      } catch (e) {
        print('Geocoding error: $e');
        // Fallback to coords if geocoding fails (e.g. network issue)
      }

      setState(() {
        _currentLocation = GeoPoint(position.latitude, position.longitude);
        _locationText = completeAddress;
        if (fetchedCity.isNotEmpty) _cityCtrl.text = fetchedCity;
        if (fetchedWard.isNotEmpty) _wardCtrl.text = fetchedWard;
      });
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Location & Address updated from GPS')),
        );
      }

    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocationUpdating = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      final data = {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'ward': _wardCtrl.text.trim(), 
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (_currentLocation != null) {
        data['location'] = _currentLocation!;
      }

      // 1. Update Firestore
      // Security rule: allow update: if isSignedIn() && isOwner(userId);
      // We are updating users/{uid} where uid == request.auth.uid
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        data, 
        SetOptions(merge: true),
      );

      // 2. Update LocalPrefs (for offline access/speed)
      await LocalPrefs.setString(LocalPrefs.keyName, data['name'] as String);
      await LocalPrefs.setString(LocalPrefs.keyPhone, data['phone'] as String);
      await LocalPrefs.setString(LocalPrefs.keyCity, data['city'] as String);
      if (data['ward'] != null) {
        await LocalPrefs.setString(LocalPrefs.keyWard, data['ward'] as String);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate reload needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _wardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Name is required' : null,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      autovalidateMode: AutovalidateMode.onUserInteraction, // Show error immediately
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Phone is required';
                        }
                        String pattern = r'^[0-9]{10}$';
                        RegExp regExp = RegExp(pattern);
                        if (!regExp.hasMatch(v.trim())) {
                          return 'Phone number must be exactly 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _wardCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ward (Optional)',
                        prefixIcon: Icon(Icons.map),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Location Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Location', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.primaryOrange),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_locationText)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isLocationUpdating ? null : _updateLocation,
                              icon: _isLocationUpdating 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                                : const Icon(Icons.my_location),
                              label: Text(_isLocationUpdating ? 'Updating...' : 'Get Current GPS Location'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
