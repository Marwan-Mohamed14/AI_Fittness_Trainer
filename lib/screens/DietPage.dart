import 'package:ai_personal_trainer/models/MealData.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_personal_trainer/controllers/Profilecontroller.dart';
import 'package:ai_personal_trainer/utils/responsive.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
         appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.food_bank, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Diet Plan',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: _reloadDietPlan,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<DailyMealPlan?>(
        future: _profileController.loadDietPlan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your diet plan...',
                    style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6)),
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
                  Icon(
                    Icons.restaurant_menu_outlined,
                    size: 64,
                    color: theme.colorScheme.onBackground.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No diet plan found',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your profile to generate one',
                    style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/age-screen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Set Up Profile', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final mealPlan = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DailyGoalCard(mealPlan: mealPlan),
                  const SizedBox(height: 24),
                  Text(
                    "Today's Meals",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...mealPlan.meals.asMap().entries.map((entry) {
                    final index = entry.key;
                    final meal = entry.value;
                    final mealTitles = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Meal 5'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _MealCard(
                        title: index < mealTitles.length ? mealTitles[index] : 'Meal ${index + 1}',
                        meal: meal,
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final DailyMealPlan mealPlan;

  const _DailyGoalCard({required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final targetCalories = mealPlan.targetCalories;
    final currentCalories = mealPlan.totalCalories;
    final proteinTarget = (targetCalories * 0.3 / 4).round();
    final carbsTarget = (targetCalories * 0.4 / 4).round();
    final fatTarget = (targetCalories * 0.3 / 9).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(24),
        border: !isDark ? Border.all(color: Colors.black.withOpacity(0.15), width: 1.5) : null,
        boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.track_changes, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Daily Goal',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$currentCalories / $targetCalories kcal',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _MacroProgressBar(label: 'Carbs', current: mealPlan.totalCarbs, target: carbsTarget, color: Colors.green),
          const SizedBox(height: 12),
          _MacroProgressBar(label: 'Protein', current: mealPlan.totalProtein, target: proteinTarget, color: Colors.blue),
          const SizedBox(height: 12),
          _MacroProgressBar(label: 'Fat', current: mealPlan.totalFat, target: fatTarget, color: Colors.orange),
        ],
      ),
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final int current;
  final int target;
  final Color color;

  const _MacroProgressBar({required this.label, required this.current, required this.target, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('${current}g', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: theme.colorScheme.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final MealData meal;

  const _MealCard({required this.title, required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foodItems = _parseFoodItems(meal.portions, meal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('${meal.calories} kcal', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        ...foodItems.map((foodItem) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(foodItem['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      if (foodItem['serving']!.isNotEmpty)
                        Text(foodItem['serving']!, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                  
                    Text('P: ${foodItem['protein']}g C: ${foodItem['carbs']}g', 
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 11)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Helper to parse portions string into items
  List<Map<String, dynamic>> _parseFoodItems(String portions, MealData meal) {
    if (portions.isEmpty) return [];
    final items = portions.split(RegExp(r'[,;\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final foodItems = items.where((item) {
      final lowerItem = item.toLowerCase();
      return !RegExp(r'\b(protein|carbs?|fats?)\b').hasMatch(lowerItem) && !RegExp(r'^\d+\.?\d*g?\)?$').hasMatch(lowerItem);
    }).toList();

    return foodItems.asMap().entries.map((entry) {
      final item = entry.value;
      final calorieMatch = RegExp(r'\((\d+)\s*calor').firstMatch(item);
      final itemCalories = calorieMatch != null ? int.parse(calorieMatch.group(1)!) : 0;
      String name = item.replaceAll(RegExp(r'\(\d+\s*calor.*'), '').trim();
      String serving = '';
      final servingMatch = RegExp(r'^([\d.]+\s*(?:cup|g|oz|bowl|tbsp|tsp|slice|piece)?s?)\s+(.+)', caseSensitive: false).firstMatch(name);
      if (servingMatch != null) {
        serving = servingMatch.group(1)?.trim() ?? '';
        name = servingMatch.group(2)?.trim() ?? name;
      }
      final ratio = meal.calories > 0 && itemCalories > 0 ? itemCalories / meal.calories : 1.0 / foodItems.length;
      return {
        'name': name,
        'serving': serving,
        'calories': itemCalories,
        'protein': (meal.protein * ratio).round(),
        'carbs': (meal.carbs * ratio).round(),
        'fat': (meal.fat * ratio).round(),
      };
    }).toList();
  }
}