class GymModel {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final double distanceKm;

  GymModel({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    this.distanceKm = 0,
  });

  GymModel copyWith({double? distanceKm}) => GymModel(
        id: id,
        name: name,
        address: address,
        lat: lat,
        lon: lon,
        distanceKm: distanceKm ?? this.distanceKm,
      );

  factory GymModel.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] ?? {};
    return GymModel(
      id: props['place_id']?.toString() ?? DateTime.now().toString(),
      name: props['name'] ?? props['address_line1'] ?? 'Local Gym',
      address: props['address_line2'] ?? props['city'] ?? 'Near you',
      lat: props['lat']?.toDouble() ?? 0.0,
      lon: props['lon']?.toDouble() ?? 0.0,
      distanceKm: (props['distance'] ?? 0) / 1000.0,
    );
  }
}