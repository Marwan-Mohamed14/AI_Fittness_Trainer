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
  bool _isLoading = true;
  String _errorMessage = '';

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
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchGyms() async {
    if (_currentPosition == null) return;
    try {
      final gyms = await _gymService.fetchNearbyGyms(
        _currentPosition!.latitude, 
        _currentPosition!.longitude,
        radiusMeters: 15000,
      );
      setState(() {
        _gyms = gyms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F111A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.location_on, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              'Nearby Gyms',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (_currentPosition != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                initialZoom: 14.0,
                backgroundColor: const Color(0xFF0F111A),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 60,
                      height: 60,
                      child: const Icon(Icons.my_location, color: Colors.deepPurple, size: 30),
                    ),
                    ..._gyms.map((gym) => Marker(
                      point: LatLng(gym.lat, gym.lon),
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                    )),
                  ],
                ),
              ],
            )
          else
            Center(child: _errorMessage.isNotEmpty 
              ? Text(_errorMessage, style: const TextStyle(color: Colors.white))
              : const CircularProgressIndicator(color: Colors.deepPurple)
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F111A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, -5))
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Found Gyms",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${_gyms.length} results", 
                          style: const TextStyle(color: Colors.deepPurple)
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _gyms.isEmpty 
                        ? Center(child: Text(_isLoading ? "Scanning area..." : "No gyms found nearby.", style: const TextStyle(color: Colors.grey))) 
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _gyms.length,
                            padding: const EdgeInsets.only(bottom: 20),
                            itemBuilder: (context, index) {
                              return GymCard(gym: _gyms[index]);
                            },
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