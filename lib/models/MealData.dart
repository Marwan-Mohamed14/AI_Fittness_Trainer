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
      print('📄 Diet plan preview (first 500 chars): ${dietPlanText.length > 500 ? dietPlanText.substring(0, 500) + "..." : dietPlanText}');

     
      final List<MealData> meals = [];
      
    
      final mealTypes = ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK', 'MEAL 1', 'MEAL 2', 'MEAL 3', 'MEAL 4', 'MEAL 5'];
      
      for (final mealType in mealTypes) {
        final meal = _extractMeal(dietPlanText, mealType);
        if (meal != null) {
          print('✅ Found $mealType: ${meal.name}');
          meals.add(meal);
        } else {
          print('⚠️ No $mealType found');
        }
      }
      
    
      if (meals.isEmpty) {
        final anyMealPattern = RegExp(
          r'\[(BREAKFAST|LUNCH|DINNER|SNACK|MEAL\s*\d+)\].*?(?=\[|DAILY_TOTAL|===|$)',
          dotAll: true, //allows . 
          caseSensitive: false, //ignore capitalization
        );
        
        final matches = anyMealPattern.allMatches(dietPlanText);
        for (final match in matches) {
          final mealType = match.group(1) ?? '';
          final meal = _extractMeal(dietPlanText, mealType);
          if (meal != null && !meals.any((m) => m.name == meal.name)) {
            meals.add(meal);
          }
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
      int calculatedFat = meals.fold(0, (sum, meal) => sum + meal.fat);//iterates through meals to add neutrition facts

    
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
          : totalFat;//compare extracted totals to calculated totals to choose most reliable

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
      var mealText = '';
      
    
      if (mealType.toUpperCase() == 'SNACK') {
        final snackStart = text.toUpperCase().indexOf('[SNACK]');
        if (snackStart != -1) {
          final snackContentStart = text.indexOf(']', snackStart) + 1;
          final dailyTotalStart = text.toUpperCase().indexOf('[DAILY_TOTAL]', snackContentStart);
          if (dailyTotalStart != -1) {
            mealText = text.substring(snackContentStart, dailyTotalStart).trim();
            print('📝 SNACK: Manually extracted content (${mealText.length} chars)');
          } else {
         
            mealText = text.substring(snackContentStart).trim();
            print('📝 SNACK: Extracted to end of text (${mealText.length} chars)');
          }
        }
      } else {
     
        final mealPattern = RegExp(
          '\\[$mealType\\](.*?)(?=\\[(?:BREAKFAST|LUNCH|DINNER|SNACK|MEAL|DAILY_TOTAL|===)|\\Z)',
          dotAll: true,
          caseSensitive: false,
        );

        final mealMatch = mealPattern.firstMatch(text);
        if (mealMatch == null) {
          print('⚠️ No match found for $mealType');
          return null;
        }

        mealText = mealMatch.group(1)?.trim() ?? '';
      }
      
      if (mealText.isEmpty) {
        print('⚠️ Empty meal text for $mealType');
        return null;
      }
      
      print('📝 Extracting $mealType - meal text length: ${mealText.length}');
      print('📝 First 300 chars: ${mealText.length > 300 ? mealText.substring(0, 300) + "..." : mealText}');

 
      String name = '';
      final nameMatch = RegExp(r'Name:\s*(.+)', caseSensitive: false)
          .firstMatch(mealText);
      if (nameMatch != null) {
        name = nameMatch.group(1)?.trim() ?? '';
      }

    
      String portions = '';
   

      final portionMatch = RegExp(
        r'Portions?:\s*\n?(.*?)(?=\n\s*(?:Calories|Protein|Carbs|Fat|Name|\[|DAILY_TOTAL))',
        dotAll: true,
        caseSensitive: false,
      ).firstMatch(mealText);
      
      if (portionMatch != null) {
        portions = portionMatch.group(1)?.trim() ?? '';
        print('📝 Raw portions for $mealType: "$portions"');
        
        if (portions.isNotEmpty) {
        
          portions = portions
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .map((line) => line.replaceFirst(RegExp(r'^[-•]\s*'), '')) 
              .where((line) => line.isNotEmpty) 
              .join(', '); 
          print('📝 Cleaned portions for $mealType: "$portions"');
        }
      } else {
        print('⚠️ No portion match for $mealType');
      }
      
    
      if (portions.isEmpty) {
        final portionMatchSingle = RegExp(
          r'Portions?:\s*(.+?)(?=\n\s*(?:Calories|Protein|Carbs|Fat|DAILY_TOTAL))',
          dotAll: true,
          caseSensitive: false,
        ).firstMatch(mealText);
        if (portionMatchSingle != null) {
          portions = portionMatchSingle.group(1)?.trim() ?? '';
          print('📝 Fallback portions for $mealType: "$portions"');
        }
      }


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

    final totalSectionMatch = RegExp(
      r'\[DAILY_TOTAL\].*?$',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(text);

    String totalSection = totalSectionMatch?.group(0) ?? text;

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
