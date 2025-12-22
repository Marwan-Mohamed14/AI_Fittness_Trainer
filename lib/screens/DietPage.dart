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
  DailyMealPlan? _mealPlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDietPlan();
  }

  Future<void> _loadDietPlan() async {
    setState(() => _isLoading = true);
    final plan = await _profileController.loadDietPlan();
    setState(() {
      _mealPlan = plan;
      _isLoading = false;
    });
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
            onPressed: _loadDietPlan,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
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
            )
          : _mealPlan == null
              ? Center(
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
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DailyGoalCard(mealPlan: _mealPlan!),
                        const SizedBox(height: 24),
                        _MealCard(
                          title: 'Breakfast',
                          icon: Icons.wb_sunny_outlined,
                          meal: _mealPlan!.breakfast,
                        ),
                        const SizedBox(height: 16),
                        _MealCard(
                          title: 'Lunch',
                          icon: Icons.lunch_dining_outlined,
                          meal: _mealPlan!.lunch,
                        ),
                        const SizedBox(height: 16),
                        _MealCard(
                          title: 'Dinner',
                          icon: Icons.dinner_dining_outlined,
                          meal: _mealPlan!.dinner,
                        ),
                        const SizedBox(height: 24),
                        _NotesCard(),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// ============================
// Daily Goal Card
// ============================
class _DailyGoalCard extends StatelessWidget {
  final DailyMealPlan mealPlan;

  const _DailyGoalCard({required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Text('Today\'s Nutrition',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.7))),
          const SizedBox(height: 8),
          Text('${mealPlan.totalCalories} kcal',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 24),
          _MacroRow(label: 'Protein', grams: '${mealPlan.totalProtein}g', color: Colors.blue),
          const SizedBox(height: 16),
          _MacroRow(label: 'Carbs', grams: '${mealPlan.totalCarbs}g', color: Colors.green),
          const SizedBox(height: 16),
          _MacroRow(label: 'Fat', grams: '${mealPlan.totalFat}g', color: Colors.orange),
        ],
      ),
    );
  }
}

// ============================
// Macro Row
// ============================
class _MacroRow extends StatelessWidget {
  final String label;
  final String grams;
  final Color color;

  const _MacroRow({required this.label, required this.grams, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.8))),
        const Spacer(),
        Text(grams, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
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
          Text(meal.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(meal.portions, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
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