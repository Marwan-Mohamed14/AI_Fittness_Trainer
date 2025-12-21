import 'dart:math' as math;

class GymModel {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final double distanceKm;
  final double rating;
  final int userRatingsTotal;
  final String? photoReference;

  GymModel({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.distanceKm,
    this.rating = 0.0,
    this.userRatingsTotal = 0,
    this.photoReference,
  });

  factory GymModel.fromGoogle(Map<String, dynamic> json, double uLat, double uLon) {
    final loc = json['geometry']['location'];
    final lat = (loc['lat'] as num).toDouble();
    final lon = (loc['lng'] as num).toDouble();

    String? photoRef;
    if (json['photos'] != null && (json['photos'] as List).isNotEmpty) {
      photoRef = json['photos'][0]['photo_reference'];
    }

    return GymModel(
      id: json['place_id'] ?? '',
      name: json['name'] ?? 'Unknown Gym',
      address: json['vicinity'] ?? '',
      lat: lat,
      lon: lon,
      rating: (json['rating'] ?? 0.0).toDouble(),
      userRatingsTotal: json['user_ratings_total'] ?? 0,
      photoReference: photoRef,
      distanceKm: _distance(uLat, uLon, lat, lon),
    );
  }

  static double _distance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg(lat2 - lat1);
    final dLon = _deg(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg(lat1)) * math.cos(_deg(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _deg(double d) => d * (math.pi / 180);
}