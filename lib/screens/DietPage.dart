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
    // Force rebuild by calling setState with a new future
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, color: theme.colorScheme.primary),
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
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
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
                  Icon(Icons.restaurant_menu_outlined, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No diet plan found',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your profile to generate one',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/age-screen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: Text('Set Up Profile', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                  ),
                ],
              ),
            );
          }

          final mealPlan = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DailyGoalCard(mealPlan: mealPlan),
                  const SizedBox(height: 24),
                  // Dynamic meal cards
                  ...mealPlan.meals.asMap().entries.map((entry) {
                    final index = entry.key;
                    final meal = entry.value;
                    final mealTitles = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Meal 5'];
                    final mealIcons = [
                      Icons.wb_sunny_outlined,
                      Icons.lunch_dining_outlined,
                      Icons.dinner_dining_outlined,
                      Icons.fastfood_outlined,
                      Icons.restaurant_outlined,
                    ];
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < mealPlan.meals.length - 1 ? 16 : 0),
                      child: _MealCard(
                        title: index < mealTitles.length ? mealTitles[index] : 'Meal ${index + 1}',
                        icon: index < mealIcons.length ? mealIcons[index] : Icons.restaurant_outlined,
                        meal: meal,
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  _NotesCard(),
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
// Daily Goal Card with Progress Bars
// ============================
class _DailyGoalCard extends StatelessWidget {
  final DailyMealPlan mealPlan;

  const _DailyGoalCard({required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetCalories = mealPlan.targetCalories;
    final currentCalories = mealPlan.totalCalories;

    // Macro targets (can be adjusted based on goals)
    final proteinTarget = (targetCalories * 0.3 / 4).round(); // 30% of calories from protein
    final carbsTarget = (targetCalories * 0.4 / 4).round(); // 40% of calories from carbs
    final fatTarget = (targetCalories * 0.3 / 9).round(); // 30% of calories from fat

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Goal',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.9),
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 12),
          Text('$currentCalories / $targetCalories kcal',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              )),
          const SizedBox(height: 24),
          _MacroProgressBar(
            label: 'Carbs',
            current: mealPlan.totalCarbs,
            target: carbsTarget,
            color: Colors.green,
            onPrimary: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: 16),
          _MacroProgressBar(
            label: 'Protein',
            current: mealPlan.totalProtein,
            target: proteinTarget,
            color: Colors.blue,
            onPrimary: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: 16),
          _MacroProgressBar(
            label: 'Fat',
            current: mealPlan.totalFat,
            target: fatTarget,
            color: Colors.orange,
            onPrimary: theme.colorScheme.onPrimary,
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
  final Color onPrimary;

  const _MacroProgressBar({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    required this.onPrimary,
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
              style: TextStyle(
                color: onPrimary.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${current}g',
              style: TextStyle(
                color: onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: onPrimary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}


// ============================
// Meal Card
// ============================
class _MealCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final MealData meal;

  const _MealCard({required this.title, required this.icon, required this.meal});

  // Parse food items from portions string
  List<Map<String, String>> _parseFoodItems(String portions) {
    if (portions.isEmpty) return [];
    
    // Split by common separators (comma, newline, semicolon)
    final items = portions
        .split(RegExp(r'[,;\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    
    return items.map((item) {
      // Try to extract calories if present (e.g., "150g chicken (250 kcal)")
      final calorieMatch = RegExp(r'\((\d+)\s*kcal\)').firstMatch(item);
      final calories = calorieMatch != null ? '${calorieMatch.group(1)} kcal' : '';
      
      // Remove calorie info from name
      final name = item.replaceAll(RegExp(r'\(.*?kcal.*?\)'), '').trim();
      
      return {
        'name': name,
        'calories': calories,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.onSurface.withOpacity(0.1)
              : Colors.black.withOpacity(0.15), // More visible border in light mode
          width: isDark ? 1 : 1.5, // Thicker in light mode
        ),
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${meal.calories} kcal', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
          const SizedBox(height: 12),
          // Parse portions into individual food items
          ..._parseFoodItems(meal.portions).map((foodItem) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      foodItem['name'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    foodItem['calories'] ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroChip(label: 'P', value: '${meal.protein}g', color: Colors.blue),
              _MacroChip(label: 'C', value: '${meal.carbs}g', color: Colors.green),
              _MacroChip(label: 'F', value: '${meal.fat}g', color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================
// Macro Chip
// ============================
class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text(value, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}

// ============================
// Notes Card
// ============================
class _NotesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(12),
        border: !isDark
            ? Border.all(
                color: Colors.black.withOpacity(0.15),
                width: 1.5,
              )
            : null,
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is your personalized weekly plan. Same meals every day for consistency.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}