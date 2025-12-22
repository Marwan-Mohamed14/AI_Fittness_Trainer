import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/GymLocationService.dart';
import '../models/GymLocationModel.dart';
import '../widgets/GymLocationCard.dart';

class NearbyGymsScreen extends StatefulWidget {
  const NearbyGymsScreen({super.key});

  @override
  State<NearbyGymsScreen> createState() => _NearbyGymsScreenState();
}

class _NearbyGymsScreenState extends State<NearbyGymsScreen> {
  final GymService _gymService = GymService();
  final MapController _mapController = MapController();
  
  Position? _currentPosition;
  List<GymModel> _gyms = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _gymService.determinePosition();
      if (position != null) {
        setState(() => _currentPosition = position);
        _fetchGyms();
      }
    } catch (e) {
      // Handle error silently or show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _fetchGyms() async {
    if (_currentPosition == null) return;
    try {
      final gyms = await _gymService.fetchNearbyGyms(
        _currentPosition!.latitude, 
        _currentPosition!.longitude,
        radiusMeters: 5000, // Search accuracy set to 2km
      );
      setState(() {
        _gyms = gyms;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nearby Gyms',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_currentPosition != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                initialZoom: 14.5,
                backgroundColor: Colors.white,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  retinaMode: RetinaMode.isHighDensity(context), // FIX: Sharp map tiles
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 60, height: 60,
                      child: const Icon(Icons.my_location, color: Colors.indigo, size: 30),
                    ),
                    ..._gyms.map((gym) => Marker(
                      point: LatLng(gym.lat, gym.lon),
                      width: 40, height: 40,
                      child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                    )),
                  ],
                ),
              ],
            )
          else
            Center(
              child: CircularProgressIndicator(color: theme.colorScheme.primary),
            ),

          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: !isDark
                      ? Border(
                          top: BorderSide(
                            color: Colors.black.withOpacity(0.08),
                            width: 1,
                          ),
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Found Gyms",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${_gyms.length} results",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _gyms.length,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemBuilder: (context, index) => GymCard(gym: _gyms[index]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}