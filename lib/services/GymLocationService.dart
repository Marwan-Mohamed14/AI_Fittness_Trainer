import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/GymLocationModel.dart';

class GymService {

final List<String> _servers = [
  'https://overpass.kumi.systems/api/interpreter',
  'https://overpass.nchc.org.tw/api/interpreter',
  'https://overpass-api.de/api/interpreter',
  'https://overpass.openstreetmap.ru/api/interpreter',
];


  // ✅ LOCATION (SAFE)
  Future<Position> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ✅ FETCH GYMS (FAST)
  Future<List<GymModel>> fetchNearbyGyms(
    double lat,
    double lon, {
    int radiusMeters = 2500,
  }) async {

    final query = '''
[out:json][timeout:8];
(
  node["amenity"="gyms"](around:$radiusMeters,$lat,$lon);
  node["leisure"="fitness_centre"](around:$radiusMeters,$lat,$lon);
);
out;
''';

    for (final server in _servers) {
      try {
        final response = await http.post(
          Uri.parse(server),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: query,
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          return _parseGyms(response.body, lat, lon);
        }
      } catch (_) {
        continue;
      }
    }

    return [];
  }

  List<GymModel> _parseGyms(
      String responseBody, double userLat, double userLon) {
    final data = json.decode(responseBody);
    final List elements = data['elements'];

    final Map<String, GymModel> gyms = {};

    for (final e in elements) {
      if (e['lat'] == null || e['lon'] == null) continue;

      final gym = GymModel.fromOverpassJson(e);

      final dist = Geolocator.distanceBetween(
        userLat,
        userLon,
        gym.lat,
        gym.lon,
      );

      gyms[gym.id] = gym.copyWith(distanceKm: dist / 1000);
    }

    final list = gyms.values.toList();
    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }
}
