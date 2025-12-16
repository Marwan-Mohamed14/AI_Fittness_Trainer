import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/GymLocationModel.dart';

class GymCard extends StatelessWidget {
  final GymModel gym;

  const GymCard({super.key, required this.gym});

  Future<void> _launchMaps() async {
    final uri = Uri.parse("google.navigation:q=${gym.lat},${gym.lon}&mode=d");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUri = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=${gym.lat},${gym.lon}");
      await launchUrl(webUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Gym Image loaded from Internet
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    // Using a random placeholder service with 'gym' keyword
                    // We add the gym ID to the URL to ensure different gyms get different random images
                    'https://loremflickr.com/320/320/gym,fitness?random=${gym.id}',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.fitness_center, color: Colors.white24),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // 2. Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            gym.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(6),
                          )
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${gym.address} • ${gym.distanceKm.toStringAsFixed(1)} km",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        const Text("4.5", style: TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text("Open Now", style: TextStyle(color: Colors.green, fontSize: 10)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 3. Navigate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _launchMaps,
              style: ElevatedButton.styleFrom(
                backgroundColor:  Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.navigation, size: 16, color: Colors.white),
              label: const Text("Navigate", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}