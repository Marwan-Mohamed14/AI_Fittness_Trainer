import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_personal_trainer/controllers/Profilecontroller.dart';
import 'package:ai_personal_trainer/models/WorkoutData.dart';
import 'package:ai_personal_trainer/utils/responsive.dart';
import 'package:ai_personal_trainer/services/exercise_video_service.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final ExerciseVideoService _videoService = ExerciseVideoService();
  WorkoutPlan? _workoutPlan;
  bool _isLoading = true;
  Map<String, String> _videoUrls = {};

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlan();
  }

  Future<void> _loadWorkoutPlan() async {
    setState(() => _isLoading = true);
    final plan = await _profileController.loadWorkoutPlan();
    
    // Load video URLs for all exercises
    final videoUrls = await _videoService.getAllVideoUrls();
    
    setState(() {
      _workoutPlan = plan;
      _videoUrls = videoUrls;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double screenPadding = Responsive.padding(context); 
    final double sectionFontSize = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16); 
    final double titleFontSize = Responsive.fontSize(context, mobile: 24, tablet: 26, desktop: 28); 
    final double buttonFontSize = Responsive.fontSize(context, mobile: 14, tablet: 16, desktop: 18); 
    final double iconSize = Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24); 
    final double exerciseIconSize = Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24); 
    final double boxPadding = Responsive.padding(context) / 2; 
    final double cardRadius = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16); 
    final double cardSpacing = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16); 
    final double smallSpacing = Responsive.fontSize(context, mobile: 6, tablet: 8, desktop: 10); 
    final double largeSpacing = Responsive.fontSize(context, mobile: 20, tablet: 24, desktop: 28); 
    final double iconCircleSize = Responsive.fontSize(context, mobile: 40, tablet: 44, desktop: 48); 
    final double tutorialFontSize = Responsive.fontSize(context, mobile: 10, tablet: 12, desktop: 14); 
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_gymnastics, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Workout Plan',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: _loadWorkoutPlan,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your workout plan...',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                  ),
                ],
              ),
            )
          : _workoutPlan == null || _workoutPlan!.days.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center_outlined, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No workout plan found',
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete your profile to generate one',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Get.toNamed('/age-screen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        child: Text('Set Up Profile', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        if (_workoutPlan!.weeklyFocus != null)
                          _WeeklyFocusCard(focus: _workoutPlan!.weeklyFocus!),
                        if (_workoutPlan!.weeklyFocus != null) const SizedBox(height: 24),
                        ..._workoutPlan!.days.asMap().entries.map((entry) {
                          final index = entry.key;
                          final day = entry.value;
                          final iconColors = [
                            Colors.orange,
                            Colors.blueAccent,
                            Colors.purpleAccent,
                            Colors.greenAccent,
                            Colors.redAccent,
                            Colors.tealAccent,
                            Colors.pinkAccent,
                          ];
                          final iconDataList = [
                            Icons.fitness_center,
                            Icons.rowing,
                            Icons.directions_run,
                            Icons.sports_mma,
                            Icons.pool,
                            Icons.directions_bike,
                            Icons.self_improvement,
                          ];
                          
                          return Column(
                            children: [
                              if (index > 0) const SizedBox(height: 24),
                              _DaySection(
                                dayTitle: day.dayTitle,
                                muscles: day.muscles,
                                duration: day.duration,
                                iconColor: iconColors[index % iconColors.length],
                                iconData: iconDataList[index % iconDataList.length],
                                exercises: day.exercises.map((e) => _ExerciseItem(
                                  name: e.name,
                                  sets: e.sets,
                                  reps: e.reps,
                                  videoUrl: e.videoUrl ?? _videoUrls[e.name.toLowerCase().trim()],
                                )).toList(),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _WeeklyFocusCard extends StatelessWidget {
  final String focus;

  const _WeeklyFocusCard({required this.focus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: !isDark
            ? Border.all(
                color: Colors.black.withOpacity(0.15),
                width: 1.5,
              )
            : null,
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.psychology,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Weekly Focus',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                focus,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _DaySection extends StatelessWidget {
  final String dayTitle;
  final String muscles;
  final String duration;
  final Color iconColor;
  final IconData iconData;
  final List<_ExerciseItem> exercises;

  const _DaySection({
    required this.dayTitle,
    required this.muscles,
    required this.duration,
    required this.iconColor,
    required this.iconData,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayTitle,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      muscles,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                duration,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...exercises.map((e) => _ExerciseCard(item: e)).toList(),
      ],
    );
  }
}

class _ExerciseItem {
  final String name;
  final String sets;
  final String reps;
  final String? videoUrl;

  _ExerciseItem({
    required this.name,
    required this.sets,
    required this.reps,
    this.videoUrl,
  });
}

class _ExerciseCard extends StatelessWidget {
  final _ExerciseItem item;

  const _ExerciseCard({
    required this.item,
  });

  Future<void> _handleVideoClick(BuildContext context) async {
    if (item.videoUrl != null && item.videoUrl!.isNotEmpty) {
      // Open video URL directly
      await _openVideoUrl(context, item.videoUrl!);
    }
  }

  Future<void> _openVideoUrl(BuildContext context, String videoUrl) async {
    try {
      String url = videoUrl.trim();
      
      // Check if it's a direct video URL - if so, prefer search URL for reliability
      bool isDirectVideo = url.contains('youtube.com/watch?v=') || url.contains('youtu.be/');
      
      // If it's a direct video URL, use search URL instead for better reliability
      // This ensures we always find videos even if the specific video ID is invalid
      if (isDirectVideo) {
        // Extract exercise name and create a search URL
        String searchQuery = item.name.replaceAll(' ', '+') + '+how+to+do+proper+form';
        url = 'https://www.youtube.com/results?search_query=$searchQuery';
      } else {
        // Convert YouTube search URLs to proper format
        url = _convertYouTubeUrl(url);
      }
      
      // Ensure URL has protocol
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final Uri uri = Uri.parse(url);
      
      // For Android, try multiple launch methods
      if (Platform.isAndroid) {
        // For search URLs, always use browser
        if (url.contains('youtube.com/results')) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Cannot launch URL');
          }
        } else if (url.contains('youtube.com/watch') || url.contains('youtu.be/')) {
          // Try YouTube app first if it's a YouTube video
          try {
            // Extract video ID
            String? videoId = _extractYouTubeVideoId(url);
            if (videoId != null) {
              // Try YouTube app intent
              final youtubeAppUri = Uri.parse('vnd.youtube:$videoId');
              if (await canLaunchUrl(youtubeAppUri)) {
                await launchUrl(youtubeAppUri);
                return;
              }
            }
          } catch (e) {
            print('⚠️ Could not open YouTube app, trying browser: $e');
          }
          
          // Fallback to browser
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Cannot launch URL');
          }
        } else {
          // Fallback to browser for any other URL
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Cannot launch URL');
          }
        }
      } else {
        // For iOS/Web, use standard launch
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Cannot launch URL');
        }
      }
    } catch (e) {
      print('❌ Error opening video URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open video. Please check your internet connection.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Convert YouTube search URLs or validate video URLs
  String _convertYouTubeUrl(String url) {
    // If it's already a valid YouTube video URL, return as is
    if (url.contains('youtube.com/watch?v=') || url.contains('youtu.be/')) {
      return url;
    }
    
    // If it's a search URL, convert to a more reliable format
    if (url.contains('youtube.com/results?search_query=')) {
      // Extract search query
      final match = RegExp(r'search_query=([^&]+)').firstMatch(url);
      if (match != null) {
        String query = match.group(1) ?? '';
        // URL decode and re-encode properly
        query = Uri.decodeComponent(query).replaceAll(' ', '+');
        // Return a proper search URL that works on mobile
        return 'https://www.youtube.com/results?search_query=$query';
      }
    }
    
    // If it's just a video ID, create proper URL
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url)) {
      return 'https://www.youtube.com/watch?v=$url';
    }
    
    return url;
  }

  // Extract YouTube video ID from URL
  String? _extractYouTubeVideoId(String url) {
    // Match youtube.com/watch?v=VIDEO_ID
    RegExp regExp = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})');
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;
    final hasVideo = item.videoUrl != null && item.videoUrl!.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(16),
        border: !isDark
            ? Border.all(
                color: Colors.black.withOpacity(0.15),
                width: 1.5,
              )
            : null,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.replaceAll('**', '').trim(),
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _InfoBadge(text: item.sets),
                    const SizedBox(width: 8),
                    _InfoBadge(text: item.reps),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: hasVideo ? () => _handleVideoClick(context) : null,
            child: Opacity(
              opacity: hasVideo ? 1.0 : 0.5,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: hasVideo 
                          ? theme.colorScheme.primaryContainer 
                          : theme.colorScheme.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasVideo ? Icons.video_library : Icons.video_library_outlined,
                      color: hasVideo 
                          ? theme.colorScheme.onPrimaryContainer 
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasVideo ? 'Watch' : 'No Video',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7), 
                      fontSize: 10
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String text;

  const _InfoBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.w600),
      ),
    );
  }
}
