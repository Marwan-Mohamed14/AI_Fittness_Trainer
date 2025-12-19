import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/Profilecontroller.dart';
import '../models/WorkoutData.dart';
import '../controllers/dailycheckupcontroller.dart';

class DailyCheckupWorkoutScreen extends StatelessWidget {
  const DailyCheckupWorkoutScreen({super.key});

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

          final today = snapshot.data!.days.first;

          // Initialize workouts **once after build**
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.initWorkout(today.exercises.length);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  today.dayTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...List.generate(today.exercises.length, (i) {
                  final exercise = today.exercises[i];
                  return _ExerciseCard(exercise: exercise, index: i, controller: controller);
                }),
                const SizedBox(height: 20),
                Obx(() {
                  final done = controller.workoutDone && controller.dietDone; // Only fully green if all done
                  return SizedBox(
                    width: double.infinity,
                    height: 55,
                    
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

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final DailyCheckupController controller;

  const _ExerciseCard({required this.exercise, required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final done = controller.workoutCompletion[index] ?? false; // Individual check
      return GestureDetector(
        onTap: () => controller.updateWorkout(index, !done), // toggle on tap
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
          color: done ? Colors.greenAccent.withOpacity(0.3) : theme.colorScheme.surface,
           borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Icon(done ? Icons.check_circle : Icons.radio_button_off,
               color: done ? Colors.green : Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${exercise.sets} • ${exercise.reps}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
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
