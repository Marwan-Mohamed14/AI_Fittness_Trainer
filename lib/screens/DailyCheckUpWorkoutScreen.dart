import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/Profilecontroller.dart';
import '../models/WorkoutData.dart';
import '../controllers/dailycheckupcontroller.dart';

class DailyCheckupWorkoutScreen extends StatelessWidget {
  const DailyCheckupWorkoutScreen({super.key});

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
            return const Center(child: Text("No workout plan found."));
          }

          final plan = snapshot.data!;
          
          // Initialize workouts: rest (index 0) + all workout days
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.initWorkout(plan.days.length + 1); // +1 for rest day
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Your Workout Day",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose one day or rest",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Rest Day Option (always shown first, index 0)
                _RestDayCard(controller: controller, index: 0),
                const SizedBox(height: 12),
                
                // All Workout Days
                ...List.generate(plan.days.length, (i) {
                  final workoutDay = plan.days[i];
                  final dayType = _getDayType(workoutDay.dayTitle);
                  return _WorkoutDayCard(
                    workoutDay: workoutDay,
                    dayType: dayType,
                    index: i + 1, // +1 because rest is at index 0
                    controller: controller,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
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
          // Radio button behavior: uncheck all others, check this one
          if (!done) {
            // Uncheck all other days
            for (var i = 0; i < controller.workoutCompletion.length; i++) {
              controller.updateWorkout(i, i == index);
            }
          } else {
            // Uncheck if already selected
            controller.updateWorkout(index, false);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: done
                ? Colors.grey.withOpacity(0.2)
                : (theme.brightness == Brightness.dark
                    ? theme.colorScheme.surface
                    : const Color(0xFFFAFBFC)), // Better contrast in light mode
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done
                  ? Colors.grey
                  : (theme.brightness == Brightness.dark
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.black.withOpacity(0.15)), // More visible border in light mode
              width: done ? 2 : (theme.brightness == Brightness.dark ? 1 : 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.dark ? 0.03 : 0.08,
                ),
                blurRadius: theme.brightness == Brightness.dark ? 6 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.radio_button_checked : Icons.radio_button_off,
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

class _WorkoutDayCard extends StatelessWidget {
  final WorkoutDay workoutDay;
  final String dayType;
  final int index;
  final DailyCheckupController controller;

  const _WorkoutDayCard({
    required this.workoutDay,
    required this.dayType,
    required this.index,
    required this.controller,
  });

  Color _getDayTypeColor(String dayType) {
    switch (dayType.toLowerCase()) {
      case 'push':
        return Colors.blue;
      case 'pull':
        return Colors.green;
      case 'legs':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final done = controller.workoutCompletion[index] ?? false;
      final restDone = controller.workoutCompletion[0] ?? false;
      final dayColor = _getDayTypeColor(dayType);
      
      return GestureDetector(
        onTap: () {
          if (!restDone || done) {
            // Radio button behavior: uncheck all others, check this one
            if (!done) {
              // Uncheck all other days (including rest)
              for (var i = 0; i < controller.workoutCompletion.length; i++) {
                controller.updateWorkout(i, i == index);
              }
            } else {
              // Uncheck if already selected
              controller.updateWorkout(index, false);
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: done
                ? dayColor.withOpacity(0.2)
                : restDone
                    ? theme.colorScheme.surface.withOpacity(0.5)
                    : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done ? dayColor : Colors.grey.withOpacity(0.3),
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
                done ? Icons.radio_button_checked : Icons.radio_button_off,
                color: done ? dayColor : Colors.grey.withOpacity(0.5),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workoutDay.dayTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: restDone && !done ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: dayColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dayType.toUpperCase(),
                            style: TextStyle(
                              color: dayColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${workoutDay.exercises.length} exercises',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.fitness_center,
                color: done ? dayColor : Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
        ),
      );
    });
  }
}
