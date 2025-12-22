import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/Profilecontroller.dart';
import '../models/MealData.dart';
import '../controllers/dailycheckupcontroller.dart';
import '../utils/responsive.dart';

class DailyCheckupMealsScreen extends StatelessWidget {
  const DailyCheckupMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

          // Generate meal labels dynamically
          final mealLabels = List.generate(
            dailyPlan.meals.length,
            (index) {
              final mealTitles = ['breakfast', 'lunch', 'dinner', 'snack', 'meal_5'];
              return index < mealTitles.length ? mealTitles[index] : 'meal_${index + 1}';
            },
          );

          // Initialize meals **once after build**
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.initMeals(mealLabels);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Dynamic meal cards
                ...dailyPlan.meals.asMap().entries.map((entry) {
                  final index = entry.key;
                  final meal = entry.value;
                  final label = mealLabels[index];
                  
                  // Get display title
                  final mealTitles = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Meal 5'];
                  final displayTitle = index < mealTitles.length 
                      ? mealTitles[index] 
                      : 'Meal ${index + 1}';
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < dailyPlan.meals.length - 1 ? 16 : 0),
                    child: _MealCard(
                      meal: meal,
                      label: label,
                      displayTitle: displayTitle,
                      controller: controller,
                    ),
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

class _MealCard extends StatelessWidget {
  final MealData meal;
  final String label;
  final String displayTitle;
  final DailyCheckupController controller;

  const _MealCard({
    required this.meal,
    required this.label,
    required this.displayTitle,
    required this.controller,
  });

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
            color: done
                ? Colors.greenAccent.withOpacity(0.3)
                : (theme.brightness == Brightness.dark
                    ? theme.colorScheme.surface
                    : const Color(0xFFFAFBFC)), // Better contrast in light mode
            borderRadius: BorderRadius.circular(20),
            border: theme.brightness == Brightness.light
                ? Border.all(
                    color: done
                        ? Colors.green.withOpacity(0.3)
                        : Colors.black.withOpacity(0.15),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.dark ? 0.05 : 0.08,
                ),
                blurRadius: theme.brightness == Brightness.dark ? 8 : 6,
                offset: Offset(0, theme.brightness == Brightness.dark ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    displayTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    done ? Icons.check_circle : Icons.radio_button_off,
                    color: done ? Colors.green : Colors.grey,
                  ),
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
