import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/GymLocationModel.dart';

class GymService {
  final String apiKey = "3deb7ebe1b3d4f0aadbb6eff278cc9a8";

  Future<Position?> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<List<GymModel>> fetchNearbyGyms(double lat, double lon, {int radiusMeters = 15000}) async {
    // We search for multiple keywords to ensure we don't miss anything in El Shorouk
    final List<String> queries = ["gym", "fitness", "gold's gym"];
    Map<String, GymModel> uniqueGyms = {};

    try {
      final futures = queries.map((q) => _querySearchAPI(lat, lon, q, radiusMeters));
      final results = await Future.wait(futures);

      for (var list in results) {
        for (var gym in list) {
          uniqueGyms[gym.id] = gym;
        }
      }

      final sortedList = uniqueGyms.values.toList();
      sortedList.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return sortedList;
    } catch (e) {
      return [];
    }
  }

  Future<List<GymModel>> _querySearchAPI(double lat, double lon, String text, int radius) async {
    // Using Autocomplete API as suggested for better coverage in sparse areas
    // bias=proximity ensures results near El Shorouk come first
    // filter=circle ensures we stay within the 15km range
    final String url = 
      "https://api.geoapify.com/v1/geocode/autocomplete?text=$text&bias=proximity:$lon,$lat&filter=circle:$lon,$lat,$radius&limit=15&apiKey=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List features = data['features'] ?? [];
      return features.map((f) => GymModel.fromJson(f)).toList();
    }
    return [];
  }
}