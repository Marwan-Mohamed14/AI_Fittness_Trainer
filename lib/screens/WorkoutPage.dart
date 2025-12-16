import 'package:flutter/material.dart';

class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0F111A,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.sports_gymnastics, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              'Workout Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
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
            children: [
              const SizedBox(height: 24),

              // ================= Weekly Focus Card =================
              const _WeeklyFocusCard(),

              const SizedBox(height: 24),

              // ================= Push Day =================
              const _DaySection(
                dayTitle: 'Push Day',
                muscles: 'CHEST • SHOULDERS • TRICEPS',
                duration: '45 Min',
                iconColor: Colors.orange,
                iconData: Icons.fitness_center,
                exercises: [
                  _ExerciseItem(
                    name: 'Barbell Bench Press',
                    sets: '4 Sets',
                    reps: '8-10 Reps',
                  ),
                  _ExerciseItem(
                    name: 'Overhead Press',
                    sets: '3 Sets',
                    reps: '10-12 Reps',
                  ),
                  _ExerciseItem(
                    name: 'Tricep Pushdowns',
                    sets: '3 Sets',
                    reps: '15 Reps',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ================= Pull Day =================
              const _DaySection(
                dayTitle: 'Pull Day',
                muscles: 'BACK • BICEPS • REAR DELT',
                duration: '50 Min',
                iconColor: Colors.blueAccent,
                iconData: Icons.rowing,
                exercises: [
                  _ExerciseItem(
                    name: 'Deadlift',
                    sets: '3 Sets',
                    reps: '5 Reps',
                  ),
                  _ExerciseItem(
                    name: 'Lat Pulldown',
                    sets: '4 Sets',
                    reps: '12 Reps',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ================= Leg Day =================
              const _DaySection(
                dayTitle: 'Leg Day',
                muscles: 'QUADS • HAMS • CALVES',
                duration: '60 Min',
                iconColor: Colors.purpleAccent,
                iconData: Icons.directions_run,
                exercises: [
                  _ExerciseItem(
                    name: 'Barbell Squat',
                    sets: '4 Sets',
                    reps: '8 Reps',
                  ),
                  _ExerciseItem(
                    name: 'Bulgarian Split Squat',
                    sets: '3 Sets',
                    reps: '10 Reps',
                  ),
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
// Widgets
// ==========================================

class _WeeklyFocusCard extends StatelessWidget {
  const _WeeklyFocusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Gradient background matching screenshot
        gradient: const LinearGradient(
          colors: [Color(0xFF3A3E85), Color(0xFF1E2230)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          // Background Icon Decoration
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.psychology,
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Weekly Focus',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Prioritize compound movements in your Push Day routine to maximize strength gains this week.',
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
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
    return Column(
      children: [
        // Section Header
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      muscles,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2230),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                duration,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Exercises
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Title + Badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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

          // Right side: Play/Tutorial Button
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1E25), // Dark reddish background
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Color(0xFFD63D47),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tutorial',
                style: TextStyle(color: Colors.grey, fontSize: 10),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF252A3A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8A93AB),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
