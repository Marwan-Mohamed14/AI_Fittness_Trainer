import 'package:ai_personal_trainer/models/MealData.dart';
import 'package:dartx/dartx.dart';
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
            child: OrientationBuilder(
              builder: (context, orientation) {
                final padding = Responsive.padding(context);
                final spacing = Responsive.spacing(context, mobile: 24, tablet: 28, desktop: 32);
                
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DailyGoalCard(mealPlan: mealPlan),
                      SizedBox(height: spacing),
                      Text(
                        "Today's Meals",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, mobile: 16, tablet: 20, desktop: 24)),
                      ...mealPlan.meals.asMap().entries.map((entry) {
                        final index = entry.key;
                        final meal = entry.value;
                        final mealTitles = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Meal 5'];

                        return Padding(
                          padding: EdgeInsets.only(bottom: Responsive.spacing(context, mobile: 20, tablet: 24, desktop: 28)),
                          child: _MealCard(
                            title: index < mealTitles.length ? mealTitles[index] : 'Meal ${index + 1}',
                            meal: meal,
                          ),
                        );
                      }),
                      SizedBox(height: Responsive.spacing(context, mobile: 40, tablet: 48, desktop: 56)),
                    ],
                  ),
                );
              },
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
      padding: Responsive.cardPadding(context),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, mobile: 24, tablet: 26, desktop: 28),
        ),
        border: !isDark ? Border.all(color: Colors.black.withOpacity(0.15), width: 1.5) : null,
        boxShadow: !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.track_changes,
                color: theme.colorScheme.primary,
                size: Responsive.iconSize(context, mobile: 20, tablet: 22, desktop: 24),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8, tablet: 10, desktop: 12)),
              Text(
                'Daily Goal',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: Responsive.fontSize(context, mobile: 14, tablet: 15, desktop: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8, tablet: 10, desktop: 12)),
          Text(
            '$currentCalories / $targetCalories kcal',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20, tablet: 24, desktop: 28)),
          _MacroProgressBar(label: 'Carbs', current: mealPlan.totalCarbs, target: carbsTarget, color: Colors.green),
          SizedBox(height: Responsive.spacing(context, mobile: 12, tablet: 14, desktop: 16)),
          _MacroProgressBar(label: 'Protein', current: mealPlan.totalProtein, target: proteinTarget, color: Colors.blue),
          SizedBox(height: Responsive.spacing(context, mobile: 12, tablet: 14, desktop: 16)),
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
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Responsive.fontSize(context, mobile: 13, tablet: 14, desktop: 15),
              ),
            ),
            Text(
              '${current}g',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, mobile: 13, tablet: 14, desktop: 15),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 6, tablet: 8, desktop: 10)),
        ClipRRect(
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, mobile: 10, tablet: 12, desktop: 14),
          ),
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
    final foodItems = _parseFoodItems(meal.portions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title, 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${meal.calories} kcal', 
                style: TextStyle(
                  color: theme.colorScheme.primary, 
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                      Text(
                        foodItem['name'] ?? '', 
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 15,
                        ),
                      ),
                      if (foodItem['amount'] != null && foodItem['amount']!.isNotEmpty)
                        Text(
                          foodItem['amount']!, 
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.5), 
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (foodItem['calories'] != null && int.parse(foodItem['calories']!) > 0)
                  Text(
                    '${foodItem['calories']} kcal',
                    style: TextStyle(
                      color: theme.colorScheme.primary.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Simplified parser - just extract name, amount, and calories
  List<Map<String, String?>> _parseFoodItems(String portions) {
    if (portions.isEmpty) return [];
    
    // Split by newlines (each food item is on its own line)
    final items = portions
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return items.map((item) {
      // Format: "Food name: amount → calorieskcal"
      // Example: "Grilled chicken breast: 250g → 360kcal"
      
      final parts = item.split('→');
      final beforeArrow = parts.isNotEmpty ? parts[0].trim() : item;
      final afterArrow = parts.length > 1 ? parts[1].trim() : '';
      
      // Extract name and amount
      String name = '';
      String amount = '';
      
      if (beforeArrow.contains(':')) {
        final colonSplit = beforeArrow.split(':');
        name = colonSplit[0].trim();
        amount = colonSplit.length > 1 ? colonSplit[1].trim() : '';
      } else {
        name = beforeArrow;
      }
      
      // Extract calories
      int? calories;
      final calorieMatch = RegExp(r'(\d+)kcal').firstMatch(afterArrow);
      if (calorieMatch != null) {
        calories = int.tryParse(calorieMatch.group(1)!);
      }

      return {
        'name': name,
        'amount': amount,
        'calories': calories?.toString(),
      };
    }).toList();
  }
}