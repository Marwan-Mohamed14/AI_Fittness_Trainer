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
  final List<MealData> meals;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int targetCalories; 

  DailyMealPlan({
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.targetCalories = 2000,
  });
}

class DietPlanParser {

  static DailyMealPlan? parseDietPlan(String dietPlanText) {
    try {
      print('🔍 Parsing diet plan...');
      print('📄 Diet plan text length: ${dietPlanText.length} characters');

      final List<MealData> meals = [];
      
      // Find all meal sections
      final mealTypes = ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK', 'MEAL 1', 'MEAL 2', 'MEAL 3', 'MEAL 4', 'MEAL 5'];
      
      for (final mealType in mealTypes) {
        final meal = _extractMeal(dietPlanText, mealType);
        if (meal != null) {
          print('✅ Found $mealType: ${meal.name} (${meal.calories} kcal)');
          meals.add(meal);
        }
      }

      if (meals.isEmpty) {
        print('⚠️ No meals found in diet plan');
        return null;
      }

      final totals = _extractDailyTotals(dietPlanText);
      
      int calculatedCalories = meals.fold(0, (sum, meal) => sum + meal.calories);
      int calculatedProtein = meals.fold(0, (sum, meal) => sum + meal.protein);
      int calculatedCarbs = meals.fold(0, (sum, meal) => sum + meal.carbs);
      int calculatedFat = meals.fold(0, (sum, meal) => sum + meal.fat);

      final totalCalories = totals['calories'] ?? 0;
      final totalProtein = totals['protein'] ?? 0;
      final totalCarbs = totals['carbs'] ?? 0;
      final totalFat = totals['fat'] ?? 0;

      final finalCalories = (totalCalories == 0 || (calculatedCalories - totalCalories).abs() > totalCalories * 0.2)
          ? calculatedCalories
          : totalCalories;
      final finalProtein = (totalProtein == 0 || (calculatedProtein - totalProtein).abs() > totalProtein * 0.2)
          ? calculatedProtein
          : totalProtein;
      final finalCarbs = (totalCarbs == 0 || (calculatedCarbs - totalCarbs).abs() > totalCarbs * 0.2)
          ? calculatedCarbs
          : totalCarbs;
      final finalFat = (totalFat == 0 || (calculatedFat - totalFat).abs() > totalFat * 0.2)
          ? calculatedFat
          : totalFat;

      print('✅ Diet plan parsed successfully! Found ${meals.length} meals');
      print('📊 Totals: $finalCalories kcal | P: ${finalProtein}g | C: ${finalCarbs}g | F: ${finalFat}g');

      final targetCalories = finalCalories > 0 ? finalCalories : calculatedCalories;

      return DailyMealPlan(
        meals: meals,
        totalCalories: finalCalories,
        totalProtein: finalProtein,
        totalCarbs: finalCarbs,
        totalFat: finalFat,
        targetCalories: targetCalories,
      );
    } catch (e) {
      print('❌ Error parsing diet plan: $e');
      return null;
    }
  }

 static MealData? _extractMeal(String text, String mealType) {
  try {
    final mealStartPattern = RegExp('\\[$mealType\\]', caseSensitive: false);
    final mealStartMatch = mealStartPattern.firstMatch(text);
    
    if (mealStartMatch == null) {
      return null;
    }

    final mealStart = mealStartMatch.end;

    final nextSectionPattern = RegExp(
      r'\[(BREAKFAST|LUNCH|DINNER|SNACK|MEAL\s*\d+|DAILY_TOTAL)\]',
      caseSensitive: false,
    );
    
    final nextSectionMatches = nextSectionPattern.allMatches(text);
    int mealEnd = text.length;
    
    for (final match in nextSectionMatches) {
      if (match.start > mealStart) {
        mealEnd = match.start;
        break;
      }
    }

    final mealText = text.substring(mealStart, mealEnd).trim();
    
    if (mealText.isEmpty) {
      return null;
    }
    
    print('📝 Extracting $mealType (${mealText.length} chars)');

    // Extract name
    String name = '';
    final nameMatch = RegExp(r'Name:\s*(.+?)(?=\n|$)', caseSensitive: false).firstMatch(mealText);
    if (nameMatch != null) {
      name = nameMatch.group(1)?.trim() ?? '';
    }

    // Extract portions
    String portions = '';
    final portionsMatch = RegExp(
      r'Portions?:\s*\n?(.*?)(?=\nCalories:)',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(mealText);
    
    if (portionsMatch != null) {
      portions = portionsMatch.group(1)?.trim() ?? '';
      
      if (portions.isNotEmpty) {
        portions = portions
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .map((line) {
              // Remove leading dash/bullet
              line = line.replaceFirst(RegExp(r'^[-•*]\s*'), '');
              
              // ✅ NEW: Remove the macro details (everything after the arrow including macros)
              // Keep format: "food: amount → calories" only
              // Remove: ", Xg protein, Xg carbs, Xg fat"
              line = line.replaceAll(RegExp(r',\s*\d+g\s+protein.*$'), '');
              
              return line;
            })
            .where((line) => line.isNotEmpty)
            .join('\n');
      }
    }

    // Extract declared calories
    final caloriesMatch = RegExp(
      r'Calories:\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(mealText);
    final declaredCalories = int.tryParse(caloriesMatch?.group(1) ?? '0') ?? 0;

    // Extract macros
    final proteinMatch = RegExp(r'Protein:\s*(\d+)g', caseSensitive: false).firstMatch(mealText);
    final carbsMatch = RegExp(r'Carbs:\s*(\d+)g', caseSensitive: false).firstMatch(mealText);
    final fatMatch = RegExp(r'Fat:\s*(\d+)g', caseSensitive: false).firstMatch(mealText);

    final protein = int.tryParse(proteinMatch?.group(1) ?? '0') ?? 0;
    final carbs = int.tryParse(carbsMatch?.group(1) ?? '0') ?? 0;
    final fat = int.tryParse(fatMatch?.group(1) ?? '0') ?? 0;

    final calculatedCalories = protein * 4 + carbs * 4 + fat * 9;
    final finalCalories = (calculatedCalories - declaredCalories).abs() > 150 
        ? calculatedCalories 
        : declaredCalories;

    print('   Name: $name');
    print('   Portions: ${portions.length > 50 ? portions.substring(0, 50) + "..." : portions}');
    print('   Declared: ${declaredCalories}kcal | Calculated: ${calculatedCalories}kcal');
    print('   Using final: ${finalCalories}kcal (P:${protein}g C:${carbs}g F:${fat}g)');

    return MealData(
      name: name.isNotEmpty ? name : '$mealType Meal',
      portions: portions.isNotEmpty ? portions : 'See plan',
      calories: finalCalories,
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
      final totalSectionMatch = RegExp(
        r'\[DAILY_TOTAL\](.*?)$',
        dotAll: true,
        caseSensitive: false,
      ).firstMatch(text);

      String totalSection = totalSectionMatch?.group(1) ?? text;

      int calories = _extractInt(totalSection, 'Calories:');
      int protein = _extractInt(totalSection, 'Protein:');
      int carbs = _extractInt(totalSection, 'Carbs:');
      int fat = _extractInt(totalSection, 'Fat:');

      print('✅ Extracted DAILY TOTAL: $calories kcal | P: $protein g | C: $carbs g | F: $fat g');

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