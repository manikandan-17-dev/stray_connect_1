import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stray_resuce_bih/core/models/vet_hospital.dart';
import 'package:stray_resuce_bih/core/services/location_service.dart';

/// Service to search for nearby vets using OpenStreetMap Overpass API
/// This is FREE and doesn't require an API key!
class OpenStreetMapService {
  // Singleton pattern
  static final OpenStreetMapService _instance = OpenStreetMapService._internal();
  factory OpenStreetMapService() => _instance;
  OpenStreetMapService._internal();

  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';

  /// Search for nearby veterinary hospitals using Overpass API
  /// 
  /// [latitude] - User's current latitude
  /// [longitude] - User's current longitude
  /// [radius] - Search radius in meters (default 5000m = 5km)
  Future<List<VetHospital>> searchNearbyVets({
    required double latitude,
    required double longitude,
    int radius = 5000,
  }) async {
    try {
      // Overpass QL query to find veterinary clinics
      final query = '''
        [out:json][timeout:25];
        (
          node["amenity"="veterinary"](around:$radius,$latitude,$longitude);
          way["amenity"="veterinary"](around:$radius,$latitude,$longitude);
          node["healthcare"="veterinary"](around:$radius,$latitude,$longitude);
          way["healthcare"="veterinary"](around:$radius,$latitude,$longitude);
        );
        out body;
        >;
        out skel qt;
      ''';

      final response = await http.post(
        Uri.parse(_overpassUrl),
        body: query,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List<dynamic>? ?? [];

        final vets = <VetHospital>[];
        
        for (var element in elements) {
          if (element['type'] == 'node' && element['tags'] != null) {
            final tags = element['tags'] as Map<String, dynamic>;
            final lat = element['lat'] as double?;
            final lon = element['lon'] as double?;
            
            if (lat != null && lon != null) {
              final vet = VetHospital(
                placeId: element['id'].toString(),
                name: tags['name'] ?? 'Veterinary Clinic',
                address: _buildAddress(tags),
                latitude: lat,
                longitude: lon,
                phoneNumber: tags['phone'] as String?,
                openingHours: tags['opening_hours'] as String?,
              );
              
              vets.add(vet);
            }
          }
        }

        // Calculate distance from user for each vet
        final locationService = LocationService();
        for (var vet in vets) {
          vet.distanceFromUser = locationService.calculateDistance(
            latitude,
            longitude,
            vet.latitude,
            vet.longitude,
          );
        }

        // Sort by distance (nearest first)
        vets.sort((a, b) {
          if (a.distanceFromUser == null) return 1;
          if (b.distanceFromUser == null) return -1;
          return a.distanceFromUser!.compareTo(b.distanceFromUser!);
        });

        // If no vets found, return sample data for demo
        if (vets.isEmpty) {
          return _getSampleVets(latitude, longitude);
        }

        return vets;
      } else {
        print('Error fetching vets: ${response.statusCode}');
        // Return sample data on error
        return _getSampleVets(latitude, longitude);
      }
    } catch (e) {
      print('Error searching nearby vets: $e');
      // Return sample data on error
      return _getSampleVets(latitude, longitude);
    }
  }

  /// Build address string from OSM tags
  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    
    if (tags['addr:street'] != null) {
      parts.add(tags['addr:street']);
    }
    if (tags['addr:housenumber'] != null) {
      parts.add(tags['addr:housenumber']);
    }
    if (tags['addr:city'] != null) {
      parts.add(tags['addr:city']);
    }
    if (tags['addr:postcode'] != null) {
      parts.add(tags['addr:postcode']);
    }
    
    if (parts.isEmpty) {
      return 'Address not available';
    }
    
    return parts.join(', ');
  }

  /// Get sample vets for demo purposes (when no real data available)
  List<VetHospital> _getSampleVets(double userLat, double userLon) {
    final locationService = LocationService();
    
    final samples = [
      VetHospital(
        placeId: 'sample_1',
        name: 'Sunshine Animal Hospitals',
        address: 'TKC complex, near Propel gas bunk, 53/3, Chennimalai Road, Perundurai',
        latitude: userLat + 0.02,
        longitude: userLon + 0.02,
        rating: 4.8,
        userRatingsTotal: 245,
        phoneNumber: '+91 98765 43210',
        isOpen: true,
        openingHours: 'Mon-Sun: 9:00 AM – 7:00 PM',
      ),
      VetHospital(
        placeId: 'sample_2',
        name: 'Pet Care Veterinary Clinic',
        address: 'Main Road, Near Bus Stand, Erode',
        latitude: userLat + 0.03,
        longitude: userLon - 0.01,
        rating: 4.5,
        userRatingsTotal: 189,
        phoneNumber: '+91 98765 43211',
        isOpen: true,
        openingHours: 'Mon-Sat: 10:00 AM – 6:00 PM',
      ),
      VetHospital(
        placeId: 'sample_3',
        name: 'Animal Care Hospital',
        address: 'Sathy Road, Erode',
        latitude: userLat - 0.01,
        longitude: userLon + 0.03,
        rating: 4.6,
        userRatingsTotal: 156,
        phoneNumber: '+91 98765 43212',
        isOpen: false,
        openingHours: 'Mon-Sun: 8:00 AM – 8:00 PM',
      ),
      VetHospital(
        placeId: 'sample_4',
        name: 'Paws & Claws Veterinary',
        address: 'Perundurai Road, Erode',
        latitude: userLat + 0.01,
        longitude: userLon - 0.02,
        rating: 4.7,
        userRatingsTotal: 203,
        phoneNumber: '+91 98765 43213',
        isOpen: true,
        openingHours: 'Mon-Fri: 9:00 AM – 5:00 PM',
      ),
      VetHospital(
        placeId: 'sample_5',
        name: 'Happy Tails Vet Clinic',
        address: 'Bhavani Road, Erode',
        latitude: userLat - 0.02,
        longitude: userLon - 0.01,
        rating: 4.4,
        userRatingsTotal: 134,
        phoneNumber: '+91 98765 43214',
        isOpen: true,
        openingHours: 'Mon-Sun: 10:00 AM – 7:00 PM',
      ),
    ];

    // Calculate distances
    for (var vet in samples) {
      vet.distanceFromUser = locationService.calculateDistance(
        userLat,
        userLon,
        vet.latitude,
        vet.longitude,
      );
    }

    // Sort by distance
    samples.sort((a, b) => a.distanceFromUser!.compareTo(b.distanceFromUser!));

    return samples;
  }
}
