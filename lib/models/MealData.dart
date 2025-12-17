class MealData {
  final String name;
  final String portions;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  MealData({
    required this.name,
    required this.portions,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class DailyMealPlan {
  final MealData breakfast;
  final MealData lunch;
  final MealData dinner;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;

  DailyMealPlan({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });
}

class DietPlanParser {
  /// Parse diet plan text into structured data
  static DailyMealPlan? parseDietPlan(String dietPlanText) {
    try {
      print('🔍 Parsing diet plan...');

      final breakfast = _extractMeal(dietPlanText, 'BREAKFAST');
      if (breakfast == null) return null;

      final lunch = _extractMeal(dietPlanText, 'LUNCH');
      if (lunch == null) return null;

      final dinner = _extractMeal(dietPlanText, 'DINNER');
      if (dinner == null) return null;

      final totals = _extractDailyTotals(dietPlanText);

      print('✅ Diet plan parsed successfully!');

      return DailyMealPlan(
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
        totalCalories: totals['calories'] ?? 0,
        totalProtein: totals['protein'] ?? 0,
        totalCarbs: totals['carbs'] ?? 0,
        totalFat: totals['fat'] ?? 0,
      );
    } catch (e) {
      print('❌ Error parsing diet plan: $e');
      return null;
    }
  }

  /// ==============================
  /// Extract a single meal
  /// ==============================
  static MealData? _extractMeal(String text, String mealType) {
    try {
      final mealPattern = RegExp(
        '$mealType[^:]*:(.*?)(?:BREAKFAST|LUNCH|DINNER|DAILY|===|\\Z)',
        dotAll: true,
        caseSensitive: false,
      );

      final mealMatch = mealPattern.firstMatch(text);
      if (mealMatch == null) return null;

      final mealText = mealMatch.group(1) ?? '';

      // ---------- Name ----------
      String name = '';
      final nameMatch = RegExp(r'Name:\s*(.+)', caseSensitive: false)
          .firstMatch(mealText);
      if (nameMatch != null) {
        name = nameMatch.group(1)?.trim() ?? '';
      }

      // ---------- Portions ----------
      String portions = '';
      final portionMatch = RegExp(
        r'Portions?:\s*(.+)',
        caseSensitive: false,
      ).firstMatch(mealText);
      if (portionMatch != null) {
        portions = portionMatch.group(1)?.trim() ?? '';
      }

      // ---------- Calories ----------
      final caloriesMatch = RegExp(
        r'Calories:\s*(\d+)|(\d+)\s*kcal',
        caseSensitive: false,
      ).firstMatch(mealText);
      final calories = int.tryParse(
            caloriesMatch?.group(1) ??
                caloriesMatch?.group(2) ??
                '0',
          ) ??
          0;

      // ---------- Macronutrients (NEW + OLD SUPPORT) ----------
      final proteinMatch = RegExp(
        r'(Protein|P):\s*(\d+)g',
        caseSensitive: false,
      ).firstMatch(mealText);

      final carbsMatch = RegExp(
        r'(Carbs|C):\s*(\d+)g',
        caseSensitive: false,
      ).firstMatch(mealText);

      final fatMatch = RegExp(
        r'(Fat|F):\s*(\d+)g',
        caseSensitive: false,
      ).firstMatch(mealText);

      final protein = int.tryParse(proteinMatch?.group(2) ?? '0') ?? 0;
      final carbs = int.tryParse(carbsMatch?.group(2) ?? '0') ?? 0;
      final fat = int.tryParse(fatMatch?.group(2) ?? '0') ?? 0;

      return MealData(
        name: name.isNotEmpty ? name : '$mealType Meal',
        portions: portions.isNotEmpty ? portions : 'See plan',
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
    } catch (e) {
      print('❌ Error extracting $mealType: $e');
      return null;
    }
  }

  static Map<String, int> _extractDailyTotals(String text) {
  try {
    // Find the [DAILY_TOTAL] section and everything after it
    final totalSectionMatch = RegExp(
      r'\[DAILY_TOTAL\].*?$',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(text);

    String totalSection = totalSectionMatch?.group(0) ?? text; // fallback to whole text

    int calories = _extractInt(totalSection, 'Calories:');
    int protein = _extractInt(totalSection, 'Protein:');
    int carbs = _extractInt(totalSection, 'Carbs:');
    int fat = _extractInt(totalSection, 'Fat:');

    print('✅ Extracted DAILY TOTAL: $calories kcal | Protein $protein g | Carbs $carbs g | Fat $fat g');

    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  } catch (e) {
    print('❌ Daily total extraction failed: $e');
    return {
      'calories': 0,
      'protein': 0,
      'carbs': 0,
      'fat': 0,
    };
  }
}

static int _extractInt(String text, String label) {
  final match = RegExp('$label\\s*(\\d+)', caseSensitive: false).firstMatch(text);
  return int.tryParse(match?.group(1) ?? '0') ?? 0;
}
}
