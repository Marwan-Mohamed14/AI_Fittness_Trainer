import 'package:flutter/material.dart';
import '../widgets/BottomNavigation.dart';

class DietPlanScreen extends StatelessWidget {
  const DietPlanScreen({super.key});

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
            Text('Diet Plan'),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _DailyGoalCard(),
              SizedBox(height: 24),
              _MealSection(
                title: 'Breakfast',
                calories: '480 kcal',
                meals: [
                  MealItem(
                    name: 'Oatmeal with Berries',
                    portion: '1 cup • 240g',
                    kcal: '150 kcal',
                  ),
                  MealItem(name: 'Almonds', portion: '15g', kcal: '90 kcal'),
                ],
              ),
              _MealSection(
                title: 'Lunch',
                calories: '430 kcal',
                meals: [
                  MealItem(
                    name: 'Grilled Chicken Breast',
                    portion: '150g',
                    kcal: '250 kcal',
                  ),
                  MealItem(
                    name: 'Quinoa Salad',
                    portion: '1 bowl',
                    kcal: '180 kcal',
                  ),
                ],
              ),
              _MealSection(
                title: 'Dinner',
                calories: '455 kcal',
                meals: [
                  MealItem(
                    name: 'Salmon Fillet',
                    portion: '200g',
                    kcal: '400 kcal',
                  ),
                  MealItem(
                    name: 'Steamed Broccoli',
                    portion: '1 cup',
                    kcal: '55 kcal',
                  ),
                ],
              ),
              _MealSection(
                title: 'Snacks',
                calories: '120 kcal',
                meals: [
                  MealItem(
                    name: 'Greek Yogurt',
                    portion: '1 cup',
                    kcal: '120 kcal',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================
// Daily Goal Card
// =============================
class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),

          // ===== Info =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Goal', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                const Text(
                  '1,450 / 2,000 kcal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _MacroBar(
                  label: 'Carbs',
                  value: 0.6,
                  grams: '120g',
                  color: Colors.green,
                ),
                const SizedBox(height: 6),
                _MacroBar(
                  label: 'Protein',
                  value: 0.8,
                  grams: '140g',
                  color: Colors.blue,
                ),
                const SizedBox(height: 6),
                _MacroBar(
                  label: 'Fat',
                  value: 0.4,
                  grams: '45g',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double value;
  final String grams;
  final Color color;

  const _MacroBar({
    required this.label,
    required this.value,
    required this.grams,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              grams,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// =============================
// Meal Section
// =============================
class _MealSection extends StatelessWidget {
  final String title;
  final String calories;
  final List<MealItem> meals;

  const _MealSection({
    required this.title,
    required this.calories,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            Text(calories, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 12),
        ...meals.map((m) => _MealCard(item: m)).toList(),
        const SizedBox(height: 24),
      ],
    );
  }
}

class MealItem {
  final String name;
  final String portion;
  final String kcal;

  const MealItem({
    required this.name,
    required this.portion,
    required this.kcal,
  });
}

class _MealCard extends StatelessWidget {
  final MealItem item;

  const _MealCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                item.portion,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Text(item.kcal, style: const TextStyle(color: Colors.deepPurple)),
        ],
      ),
    );
  }
}
