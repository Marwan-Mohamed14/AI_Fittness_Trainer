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

  factory GymModel.fromOverpassJson(Map<String, dynamic> json) {
    final tags = json['tags'] ?? {};

    return GymModel(
      id: json['id'].toString(),
      name: tags['name'] ?? tags['brand'] ?? 'Local Gym',
      address: tags['addr:street'] ??
          tags['addr:city'] ??
          'Near you',
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}
