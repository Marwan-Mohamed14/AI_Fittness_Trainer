import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/Profilecontroller.dart';
import '../models/WorkoutData.dart';
import '../controllers/dailycheckupcontroller.dart';
import '../utils/responsive.dart';

class DailyCheckupWorkoutScreen extends StatelessWidget {
  const DailyCheckupWorkoutScreen({super.key});

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

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.days.isEmpty) {
            return const Center(child: Text("No workout plan found."));
          }

          final plan = snapshot.data!;

          /// Initialize workout map once
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.initWorkout(plan.days.length + 1); // +1 for rest day
          });

          return SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.padding(context)),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                /// Rest Day
                _RestDayCard(controller: controller, index: 0),
                const SizedBox(height: 12),

                /// Workout Days
                ...List.generate(plan.days.length, (i) {
                  final workoutDay = plan.days[i];
                  final dayType = _getDayType(workoutDay.dayTitle);

                  return _WorkoutDayCard(
                    workoutDay: workoutDay,
                    dayType: dayType,
                    index: i + 1,
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

  const _RestDayCard({
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final done = controller.workoutCompletion[index] ?? false;

      return GestureDetector(
        onTap: () {
          /// Select rest day → clear others
          for (var i = 0; i < controller.workoutCompletion.length; i++) {
            controller.updateWorkout(i, i == index);
          }

          controller.saveToday();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: done
                ? Colors.grey.withOpacity(0.2)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done ? Colors.grey : Colors.grey.withOpacity(0.3),
              width: done ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.radio_button_checked : Icons.radio_button_off,
                color: Colors.grey,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Rest Day',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.hotel),
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
    final dayColor = _getDayTypeColor(dayType);

    return Obx(() {
      final done = controller.workoutCompletion[index] ?? false;

      return GestureDetector(
        onTap: () {
          /// Select workout → clear rest & others
          for (var i = 0; i < controller.workoutCompletion.length; i++) {
            controller.updateWorkout(i, i == index);
          }

          controller.saveToday();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: done
                ? dayColor.withOpacity(0.2)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done ? dayColor : Colors.grey.withOpacity(0.3),
              width: done ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.radio_button_checked : Icons.radio_button_off,
                color: done ? dayColor : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workoutDay.dayTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workoutDay.exercises.length} exercises',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.fitness_center),
            ],
          ),
        ),
      );
    });
  }
}
