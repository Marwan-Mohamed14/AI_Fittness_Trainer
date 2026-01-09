import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.initWorkout(plan.days.length + 1);
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
                
                _RestDayCard(controller: controller, index: 0),
                const SizedBox(height: 12),
                
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

  const _RestDayCard({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final done = controller.workoutCompletion[index] ?? false;
      return GestureDetector(
 

            onTap: () async {
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    Get.snackbar(
      "Error",
      "User not logged in",
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
    return;
  }

  if (!done) {
    for (var i = 0; i < controller.workoutCompletion.length; i++) {
      controller.updateWorkout(i, i == index);
    }
  } else {
    controller.updateWorkout(index, false);
  }

  await controller.saveDailyLog(userId);
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
                    : const Color(0xFFFAFBFC)), 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done
                  ? Colors.grey
                  : (theme.brightness == Brightness.dark
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.black.withOpacity(0.15)), 
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
    onTap: () async {
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    Get.snackbar(
      "Error",
      "User not logged in",
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
    return;
  }

  if (!restDone || done) {
    if (!done) {
      for (var i = 0; i < controller.workoutCompletion.length; i++) {
        controller.updateWorkout(i, i == index);
      }
    } else {
      controller.updateWorkout(index, false);
    }

    await controller.saveDailyLog(userId);
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
