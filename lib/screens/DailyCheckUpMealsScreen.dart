import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/Profilecontroller.dart';
import '../models/MealData.dart';
import '../controllers/dailycheckupcontroller.dart';

class DailyCheckupMealsScreen extends StatelessWidget {
  const DailyCheckupMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DailyCheckupController>();
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Daily Meal Checkup")),
      body: FutureBuilder<DailyMealPlan?>(
        future: profileController.loadDietPlan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No meal plan found for today."));
          }

          final dailyPlan = snapshot.data!;

          // Initialize meals **once after build**
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.initMeals(["breakfast", "lunch", "dinner"]);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _MealCard(meal: dailyPlan.breakfast, label: "breakfast", controller: controller),
                const SizedBox(height: 16),
                _MealCard(meal: dailyPlan.lunch, label: "lunch", controller: controller),
                const SizedBox(height: 16),
                _MealCard(meal: dailyPlan.dinner, label: "dinner", controller: controller),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealData meal;
  final String label;
  final DailyCheckupController controller;

  const _MealCard({required this.meal, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final done = controller.mealCompletion[label] ?? false; // Individual check
      return GestureDetector(
        onTap: () => controller.updateMeal(label, !done), // toggle on tap
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: done ? Colors.greenAccent.withOpacity(0.3) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label.capitalizeFirst!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Icon(done ? Icons.check_circle : Icons.radio_button_off,
                      color: done ? Colors.green : Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(meal.name, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                "Portions: ${meal.portions} • Calories: ${meal.calories} • Protein: ${meal.protein}g • Carbs: ${meal.carbs}g • Fat: ${meal.fat}g",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    });
  }
}
