import 'package:ai_personal_trainer/models/MealData.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_personal_trainer/controllers/Profilecontroller.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();

  Future<void> _reloadDietPlan() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628), // Dark navy background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Diet Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.deepPurple),
            onPressed: _reloadDietPlan,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<DailyMealPlan?>(
        future: _profileController.loadDietPlan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text(
                    'Loading your diet plan...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_menu_outlined,
                    size: 64,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No diet plan found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete your profile to generate one',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/age-screen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Set Up Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final mealPlan = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DailyGoalCard(mealPlan: mealPlan),
                  const SizedBox(height: 20),
                  // Dynamic meal cards
                  ...mealPlan.meals.asMap().entries.map((entry) {
                    final index = entry.key;
                    final meal = entry.value;
                    final mealTitles = [
                      'Breakfast',
                      'Lunch',
                      'Dinner',
                      'Snack',
                      'Meal 5'
                    ];

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < mealPlan.meals.length - 1 ? 16 : 0,
                      ),
                      child: _MealCard(
                        title: index < mealTitles.length
                            ? mealTitles[index]
                            : 'Meal ${index + 1}',
                        meal: meal,
                      ),
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================
// Daily Goal Card - MyFitnessPal Style
// ============================
class _DailyGoalCard extends StatelessWidget {
  final DailyMealPlan mealPlan;

  const _DailyGoalCard({required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    final targetCalories = mealPlan.targetCalories;
    final currentCalories = mealPlan.totalCalories;

    // Macro targets
    final proteinTarget = (targetCalories * 0.3 / 4).round();
    final carbsTarget = (targetCalories * 0.4 / 4).round();
    final fatTarget = (targetCalories * 0.3 / 9).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D47), // Dark blue card
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Goal',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$currentCalories / $targetCalories kcal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _MacroProgressBar(
            label: 'Carbs',
            current: mealPlan.totalCarbs,
            target: carbsTarget,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
          _MacroProgressBar(
            label: 'Protein',
            current: mealPlan.totalProtein,
            target: proteinTarget,
            color: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 12),
          _MacroProgressBar(
            label: 'Fat',
            current: mealPlan.totalFat,
            target: fatTarget,
            color: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }
}

// ============================
// Macro Progress Bar
// ============================
class _MacroProgressBar extends StatelessWidget {
  final String label;
  final int current;
  final int target;
  final Color color;

  const _MacroProgressBar({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${current}g',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ============================
// Meal Card - MyFitnessPal Style
// ============================
class _MealCard extends StatelessWidget {
  final String title;
  final MealData meal;

  const _MealCard({required this.title, required this.meal});

  List<Map<String, dynamic>> _parseFoodItems(String portions) {
    if (portions.isEmpty) return [];

    final items = portions
        .split(RegExp(r'[,;\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Filter out macro-only entries
    final foodItems = items.where((item) {
      final lowerItem = item.toLowerCase().trim();
      
      // Skip if it contains "protein", "carbs", "carb", "fat" as a word
      // This catches: "35g protein", "10g carbs", "0g fat)", etc.
      if (RegExp(r'\b(protein|carbs?|fats?)\b', caseSensitive: false).hasMatch(lowerItem)) {
        print('FILTERED OUT (contains macro keyword): "$item"');
        return false;
      }
      
      // Skip if it's just a number with optional 'g' (like "12g", "0g")
      if (RegExp(r'^\d+\.?\d*g?\)?$').hasMatch(lowerItem)) {
        print('FILTERED OUT (just number): "$item"');
        return false;
      }
      
      print('KEPT (food item): "$item"');
      return true;
    }).toList();

    print('=== FINAL FOOD ITEMS ===');
    foodItems.forEach((item) => print('- "$item"'));
    print('========================');

    // If no valid food items found, return empty list
    if (foodItems.isEmpty) return [];

    // Calculate macros per item proportionally
    final totalItems = foodItems.length;
    
    return foodItems.asMap().entries.map((entry) {
      final item = entry.value;
      
      // Extract calories from the string (e.g., "120g baked salmon (180 calories")
      final calorieMatch = RegExp(r'\((\d+)\s*calor').firstMatch(item);
      final itemCalories = calorieMatch != null ? int.parse(calorieMatch.group(1)!) : 0;

      // Remove the calories part to get clean name
      String name = item.replaceAll(RegExp(r'\(\d+\s*calor.*'), '').trim();
      String serving = '';

      // Extract serving size (e.g., "120g", "200g")
      final servingMatch = RegExp(r'^([\d.]+\s*(?:cup|g|oz|bowl|tbsp|tsp|slice|piece)?s?)\s+(.+)', caseSensitive: false).firstMatch(name);
      if (servingMatch != null) {
        serving = servingMatch.group(1)?.trim() ?? '';
        name = servingMatch.group(2)?.trim() ?? name;
      }

      // Calculate proportional macros for this item
      final calorieRatio = meal.calories > 0 && itemCalories > 0 
          ? itemCalories / meal.calories 
          : 1.0 / totalItems;
      final itemProtein = (meal.protein * calorieRatio).round();
      final itemCarbs = (meal.carbs * calorieRatio).round();
      final itemFat = (meal.fat * calorieRatio).round();

      return {
        'name': name,
        'serving': serving,
        'calories': itemCalories,
        'protein': itemProtein,
        'carbs': itemCarbs,
        'fat': itemFat,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final foodItems = _parseFoodItems(meal.portions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${meal.calories} kcal',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Macros in compact format
        Text(
          'C: ${meal.carbs}g • P: ${meal.protein}g • F: ${meal.fat}g',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        // Food Items Cards
        ...foodItems.map((foodItem) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D47), // Dark blue card
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Food name + serving
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        foodItem['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (foodItem['serving']!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            foodItem['serving']!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Right side: Calories + macros
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${foodItem['calories']} kcal',
                      style: const TextStyle(
                        color: Color(0xFFBB86FC), // Purple accent
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'P: ${foodItem['protein']}g  C: ${foodItem['carbs']}g  F: ${foodItem['fat']}g',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}