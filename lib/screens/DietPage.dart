import 'package:ai_personal_trainer/models/MealData.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_personal_trainer/controllers/Profilecontroller.dart';
import 'package:ai_personal_trainer/models/MealData.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.restaurant_menu, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              'Diet Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
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
                  CircularProgressIndicator(color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text(
                    'Loading your diet plan...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : _mealPlan == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No diet plan found',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Complete your profile to generate one',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Get.toNamed('/age-screen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: Text('Set Up Profile'),
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
                        SizedBox(height: 24),
                        _MealCard(
                          title: 'Breakfast',
                          icon: Icons.wb_sunny_outlined,
                          meal: _mealPlan!.breakfast,
                        ),
                        SizedBox(height: 16),
                        _MealCard(
                          title: 'Lunch',
                          icon: Icons.lunch_dining_outlined,
                          meal: _mealPlan!.lunch,
                        ),
                        SizedBox(height: 16),
                        _MealCard(
                          title: 'Dinner',
                          icon: Icons.dinner_dining_outlined,
                          meal: _mealPlan!.dinner,
                        ),
                        SizedBox(height: 24),
                        _NotesCard(),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// Daily Goal Card - Shows actual totals from AI plan
class _DailyGoalCard extends StatelessWidget {
  final DailyMealPlan mealPlan;

  const _DailyGoalCard({required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Nutrition',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${mealPlan.totalCalories} kcal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          _MacroRow(label: 'Protein', grams: '${mealPlan.totalProtein}g', color: Colors.blue),
          SizedBox(height: 16),
          _MacroRow(label: 'Carbs', grams: '${mealPlan.totalCarbs}g', color: Colors.green),
          SizedBox(height: 16),
          _MacroRow(label: 'Fat', grams: '${mealPlan.totalFat}g', color: Colors.orange),
        ],
      ),
    );
  }
}

// Simple row for each macro (no progress bar needed since it's exact daily intake)
class _MacroRow extends StatelessWidget {
  final String label;
  final String grams;
  final Color color;

  const _MacroRow({
    required this.label,
    required this.grams,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
        SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Spacer(),
        Text(
          grams,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Meal Card
class _MealCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final MealData meal;

  const _MealCard({
    required this.title,
    required this.icon,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepPurple, size: 24),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                '${meal.calories} kcal',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: Colors.white10),
          SizedBox(height: 12),
          Text(
            meal.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            meal.portions,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 16),
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

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.deepPurple, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is your personalized weekly plan. Same meals every day for consistency.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}