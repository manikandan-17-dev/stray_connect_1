/// Model for Veterinary Hospital/Clinic
class VetHospital {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? userRatingsTotal;
  final String? phoneNumber;
  final bool? isOpen;
  final String? openingHours;
  final String? photoReference;
  
  // Calculated field
  double? distanceFromUser;

  VetHospital({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.userRatingsTotal,
    this.phoneNumber,
    this.isOpen,
    this.openingHours,
    this.photoReference,
    this.distanceFromUser,
  });

  /// Create from Google Places API response
  factory VetHospital.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    
    return VetHospital(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? 'Unknown Vet',
      address: json['vicinity'] ?? json['formatted_address'] ?? 'Address not available',
      latitude: location?['lat'] ?? 0.0,
      longitude: location?['lng'] ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['user_ratings_total'] as int?,
      phoneNumber: json['formatted_phone_number'] as String?,
      isOpen: json['opening_hours']?['open_now'] as bool?,
      openingHours: json['opening_hours']?['weekday_text']?.join('\n') as String?,
      photoReference: (json['photos'] as List?)?.isNotEmpty == true
          ? json['photos'][0]['photo_reference']
          : null,
    );
  }

  /// Get Google Maps URL for directions
  String getDirectionsUrl() {
    return 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
  }

  /// Get display rating
  String get displayRating {
    if (rating == null) return 'No rating';
    return rating!.toStringAsFixed(1);
  }

  /// Get display distance
  String get displayDistance {
    if (distanceFromUser == null) return '';
    if (distanceFromUser! < 1) {
      return '${(distanceFromUser! * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceFromUser!.toStringAsFixed(1)} km';
  }
}
