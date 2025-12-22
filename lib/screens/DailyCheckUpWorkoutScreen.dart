import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/Profilecontroller.dart';
import '../models/WorkoutData.dart';
import '../controllers/dailycheckupcontroller.dart';

class DailyCheckupWorkoutScreen extends StatelessWidget {
  const DailyCheckupWorkoutScreen({super.key});

  // Get today's workout day based on day of week
  WorkoutDay? _getTodayWorkoutDay(WorkoutPlan plan) {
    if (plan.days.isEmpty) return null;
    
    final now = DateTime.now();
    final dayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
    
    // Calculate which day in the plan cycle (assuming plan starts from Monday)
    // If plan has fewer days than 7, cycle through them
    final planIndex = (dayOfWeek - 1) % plan.days.length;
    
    return plan.days[planIndex];
  }

  // Extract day type from dayTitle (e.g., "Push Day", "Pull Day", "Leg Day")
  String _getDayType(String dayTitle) {
    final lower = dayTitle.toLowerCase();
    if (lower.contains('push')) return 'Push';
    if (lower.contains('pull')) return 'Pull';
    if (lower.contains('leg')) return 'Legs';
    if (lower.contains('upper')) return 'Upper Body';
    if (lower.contains('lower')) return 'Lower Body';
    if (lower.contains('full')) return 'Full Body';
    if (lower.contains('cardio')) return 'Cardio';
    if (lower.contains('rest')) return 'Rest';
    // Try to extract from patterns like "Day 1 - CHEST"
    final match = RegExp(r'-\s*([A-Z\s]+)').firstMatch(dayTitle);
    if (match != null) return match.group(1)?.trim() ?? 'Workout';
    return 'Workout';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DailyCheckupController>();
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Daily Workout Checkup")),
      body: FutureBuilder<WorkoutPlan?>(
        future: profileController.loadWorkoutPlan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.days.isEmpty) {
            return const Center(child: Text("No workout plan found for today."));
          }

          final plan = snapshot.data!;
          final today = _getTodayWorkoutDay(plan);
          
          if (today == null) {
            return const Center(child: Text("No workout plan found for today."));
          }

          final dayType = _getDayType(today.dayTitle);
          final isRestDay = dayType.toLowerCase() == 'rest' || today.exercises.isEmpty;

          // Initialize workouts **once after build** (including rest option)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Add 1 for rest option
            controller.initWorkout(isRestDay ? 1 : today.exercises.length + 1);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getDayTypeColor(dayType).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getDayTypeColor(dayType),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getDayTypeIcon(dayType),
                        color: _getDayTypeColor(dayType),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dayType.toUpperCase(),
                        style: TextStyle(
                          color: _getDayTypeColor(dayType),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  today.dayTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // Rest Day Option (always shown first)
                _RestDayCard(controller: controller, index: 0),
                const SizedBox(height: 12),
                
                // Exercises (only if not rest day)
                if (!isRestDay) ...[
                  ...List.generate(today.exercises.length, (i) {
                    final exercise = today.exercises[i];
                    return _ExerciseCard(
                      exercise: exercise,
                      index: i + 1, // +1 because rest is at index 0
                      controller: controller,
                    );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getDayTypeColor(String dayType) {
    switch (dayType.toLowerCase()) {
      case 'push':
        return Colors.blue;
      case 'pull':
        return Colors.green;
      case 'legs':
        return Colors.orange;
      case 'rest':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  IconData _getDayTypeIcon(String dayType) {
    switch (dayType.toLowerCase()) {
      case 'push':
        return Icons.arrow_upward;
      case 'pull':
        return Icons.arrow_downward;
      case 'legs':
        return Icons.accessibility_new;
      case 'rest':
        return Icons.hotel;
      default:
        return Icons.fitness_center;
    }
  }
}

class _RestDayCard extends StatelessWidget {
  final DailyCheckupController controller;
  final int index;

  const _RestDayCard({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final done = controller.workoutCompletion[index] ?? false;
      return GestureDetector(
        onTap: () {
          controller.updateWorkout(index, !done);
          // If rest is selected, uncheck all exercises
          if (!done) {
            for (var i = index + 1; i < controller.workoutCompletion.length; i++) {
              controller.updateWorkout(i, false);
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: done ? Colors.grey.withOpacity(0.3) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done ? Colors.grey : Colors.grey.withOpacity(0.3),
              width: done ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.radio_button_off,
                color: done ? Colors.grey : Colors.grey.withOpacity(0.5),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rest Day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take a break and recover',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.hotel,
                color: done ? Colors.grey : Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final DailyCheckupController controller;

  const _ExerciseCard({required this.exercise, required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final done = controller.workoutCompletion[index] ?? false;
      final restDone = controller.workoutCompletion[0] ?? false;
      
      return GestureDetector(
        onTap: () {
          if (!restDone) {
            controller.updateWorkout(index, !done);
            // If exercise is selected, uncheck rest
            if (!done) {
              controller.updateWorkout(0, false);
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: done
                ? Colors.greenAccent.withOpacity(0.3)
                : restDone
                    ? theme.colorScheme.surface.withOpacity(0.5)
                    : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.radio_button_off,
                color: done
                    ? Colors.green
                    : restDone
                        ? Colors.grey.withOpacity(0.3)
                        : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: restDone ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.sets} • ${exercise.reps}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
