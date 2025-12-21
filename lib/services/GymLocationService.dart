import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/GymLocationModel.dart';

class GymService {
  final String googleKey = "AIzaSyDihfAQz0r4eirneNKMtv5QYhqWqktj054";

  Future<Position?> determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return null;
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<GymModel>> fetchNearbyGyms(double lat, double lon, {int radiusMeters = 6000}) async {
    final url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=$lat,$lon"
        "&radius=$radiusMeters"
        "&type=gym"
        "&key=$googleKey";

   try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return [];

    final data = json.decode(res.body);
    final List results = data['results'] ?? [];

    // Filter results locally to strictly match "gym" in types 
    // This prevents accidental "Yoga" or "Parks" if they don't have gym services
    return results
        .map((g) => GymModel.fromGoogle(g, lat, lon))
        .where((gym) => 
            gym.name.toLowerCase().contains('gym') || 
            gym.name.toLowerCase().contains('fitness') ||
            gym.name.toLowerCase().contains('crossfit'))
        .toList();
  } catch (e) {
    return [];
  }
  }
}