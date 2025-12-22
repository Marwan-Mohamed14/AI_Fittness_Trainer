import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_personal_trainer/controllers/Profilecontroller.dart';
import 'package:ai_personal_trainer/models/WorkoutData.dart';
import 'package:ai_personal_trainer/utils/responsive.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();
  WorkoutPlan? _workoutPlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlan();
  }

  Future<void> _loadWorkoutPlan() async {
    setState(() => _isLoading = true);
    final plan = await _profileController.loadWorkoutPlan();
    setState(() {
      _workoutPlan = plan;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // ===== Responsive variables =====
    final double screenPadding = Responsive.padding(context); // general padding
    final double sectionFontSize = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16); // body text
    final double titleFontSize = Responsive.fontSize(context, mobile: 24, tablet: 26, desktop: 28); // headings
    final double buttonFontSize = Responsive.fontSize(context, mobile: 14, tablet: 16, desktop: 18); // button text
    final double iconSize = Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24); // icons
    final double exerciseIconSize = Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24); // exercise card icon
    final double boxPadding = Responsive.padding(context) / 2; // inside cards
    final double cardRadius = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16); // card border radius
    final double cardSpacing = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16); // spacing between cards
    final double smallSpacing = Responsive.fontSize(context, mobile: 6, tablet: 8, desktop: 10); // small spacing
    final double largeSpacing = Responsive.fontSize(context, mobile: 20, tablet: 24, desktop: 28); // large spacing
    final double iconCircleSize = Responsive.fontSize(context, mobile: 40, tablet: 44, desktop: 48); // circle around icons
    final double tutorialFontSize = Responsive.fontSize(context, mobile: 10, tablet: 12, desktop: 14); // small text under icons

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

// ==========================================
// Weekly Focus Card
// ==========================================
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

// ==========================================
// Day Section
// ==========================================
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

  _ExerciseItem({
    required this.name,
    required this.sets,
    required this.reps,
  });
}

class _ExerciseCard extends StatelessWidget {
  final _ExerciseItem item;

  const _ExerciseCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;
    
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
                  item.name,
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
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: theme.colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tutorial',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 10),
              ),
            ],
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
