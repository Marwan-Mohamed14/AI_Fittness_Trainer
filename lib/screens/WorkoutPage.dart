import 'package:flutter/material.dart';

class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 24),
              _WeeklyFocusCard(),
              SizedBox(height: 24),
              _DaySection(
                dayTitle: 'Push Day',
                muscles: 'CHEST • SHOULDERS • TRICEPS',
                duration: '45 Min',
                iconColor: Colors.orange,
                iconData: Icons.fitness_center,
                exercises: [
                  _ExerciseItem(name: 'Barbell Bench Press', sets: '4 Sets', reps: '8-10 Reps'),
                  _ExerciseItem(name: 'Overhead Press', sets: '3 Sets', reps: '10-12 Reps'),
                  _ExerciseItem(name: 'Tricep Pushdowns', sets: '3 Sets', reps: '15 Reps'),
                ],
              ),
              SizedBox(height: 24),
              _DaySection(
                dayTitle: 'Pull Day',
                muscles: 'BACK • BICEPS • REAR DELT',
                duration: '50 Min',
                iconColor: Colors.blueAccent,
                iconData: Icons.rowing,
                exercises: [
                  _ExerciseItem(name: 'Deadlift', sets: '3 Sets', reps: '5 Reps'),
                  _ExerciseItem(name: 'Lat Pulldown', sets: '4 Sets', reps: '12 Reps'),
                ],
              ),
              SizedBox(height: 24),
              _DaySection(
                dayTitle: 'Leg Day',
                muscles: 'QUADS • HAMS • CALVES',
                duration: '60 Min',
                iconColor: Colors.purpleAccent,
                iconData: Icons.directions_run,
                exercises: [
                  _ExerciseItem(name: 'Barbell Squat', sets: '4 Sets', reps: '8 Reps'),
                  _ExerciseItem(name: 'Bulgarian Split Squat', sets: '3 Sets', reps: '10 Reps'),
                ],
              ),
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
  const _WeeklyFocusCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.surface
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
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
                'Prioritize compound movements in your Push Day routine to maximize strength gains this week.',
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

  const _ExerciseItem({
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
