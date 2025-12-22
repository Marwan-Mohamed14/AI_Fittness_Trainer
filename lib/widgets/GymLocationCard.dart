import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/GymLocationModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GymCard extends StatelessWidget {
  final GymModel gym;
  static final String googleKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? "";

  const GymCard({super.key, required this.gym});

  Future<void> _launchMaps() async {
    final uri = Uri.parse("google.navigation:q=${gym.lat},${gym.lon}&mode=d");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=${gym.lat},${gym.lon}");
      await launchUrl(webUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Generate actual Google Places photo URL
    final String imageUrl = gym.photoReference != null
        ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${gym.photoReference}&key=$googleKey"
        : 'https://loremflickr.com/320/320/gym,fitness?random=${gym.id}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2230) : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.15), // More visible border
          width: isDark ? 1 : 1.5, // Thicker in light mode
        ),
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(
                          Icons.fitness_center,
                          color: isDark ? Colors.white24 : Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gym.name,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${gym.address} • ${gym.distanceKm.toStringAsFixed(1)} km",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "${gym.rating}",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _launchMaps,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.navigation, size: 16, color: Colors.white),
              label: const Text(
                "Navigate",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}