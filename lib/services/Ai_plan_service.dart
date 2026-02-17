import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_personal_trainer/models/onboarding_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiPlanService {
  final String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  final String _apiKey = dotenv.env['AI_API_KEY'] ?? '';
  static const String _model = 'llama-3.3-70b-versatile';

  Future<Map<String, String>> generateWeeklyPlan(OnboardingData userData) async {
    print('\n🤖 Starting AI plan generation...');
    print('📊 User data received:');
    print('   - Age: ${userData.age}');
    print('   - Weight: ${userData.weight}kg → Target: ${userData.targetWeight}kg');
    print('   - Goal: ${userData.workoutGoal}');
    print('   - Training days: ${userData.trainingDays}');
    print('   - Location: ${userData.trainingLocation}');

    try {
      final prompt = _buildWeeklyPlanPrompt(userData);
      final response = await _callGroqAPI(prompt);
      final plans = _parsePlans(response);

      print('\n✅ Plans generated successfully!');
      return plans;
    } catch (e) {
      print('❌ Error generating plans: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // CALORIE CALCULATOR
  // ─────────────────────────────────────────────
  // ═══════════════════════════════════════════════════
  // STEP 1 — CALORIE CALCULATOR
  // Formula: Mifflin-St Jeor BMR × Activity × Goal
  // ═══════════════════════════════════════════════════
  int _calculateBaseCalories(OnboardingData userData) {
    final double weight      = userData.weight?.toDouble()       ?? 70;
    final double targetWeight= userData.targetWeight?.toDouble() ?? weight;
    final double height      = userData.height?.toDouble()       ?? 175;
    final int    age         = userData.age                      ?? 25;
    final bool   isMale      = userData.gender?.toLowerCase()    == 'male';
    final int    days        = userData.trainingDays             ?? 0;

    // ── 1A. Adjust BMR weight for obese users (BMI > 30) ──
    // Prevents over-estimating metabolism for obese individuals
    final double bmi = weight / ((height / 100) * (height / 100));
    final double bmrWeight;
    if (bmi > 30) {
      // Devine ideal body weight formula
      final double idealWeight = isMale
          ? 50.0 + 2.3 * ((height - 152.4) / 2.54)
          : 45.5 + 2.3 * ((height - 152.4) / 2.54);
      // Adjusted = ideal + 25% of excess
      bmrWeight = idealWeight + 0.25 * (weight - idealWeight);
      print('   BMI: ${bmi.toStringAsFixed(1)} → Obese, adjusted BMR weight: ${bmrWeight.toStringAsFixed(1)}kg');
    } else {
      bmrWeight = weight;
      print('   BMI: ${bmi.toStringAsFixed(1)} → Normal, using actual weight: ${weight}kg');
    }

    // ── 1B. Mifflin-St Jeor BMR ──
    final double bmr = (10 * bmrWeight) + (6.25 * height) - (5 * age) + (isMale ? 5 : -161);

    // ── 1C. TDEE: BMR × Activity multiplier ──
    final double activity;
    if      (days >= 6) activity = 1.90;   // 6-7 days: athlete
    else if (days >= 5) activity = 1.725;  // 5 days:   very active
    else if (days >= 3) activity = 1.55;   // 3-4 days: moderately active
    else if (days >= 1) activity = 1.375;  // 1-2 days: lightly active
    else                activity = 1.20;   // 0 days:   sedentary
    final double tdee = bmr * activity;

    // ── 1D. Goal adjustment based on weight difference ──
    //
    // CUTTING  → calorie DEFICIT  (lose fat)
    // BULKING  → calorie SURPLUS  (gain muscle/weight)
    // SAME     → use workout goal to decide small surplus or maintenance
    //
    final double diff          = targetWeight - weight; // negative = cutting, positive = bulking
    final double kg            = diff.abs();
    final double adjustment;
    final String label;

    if (diff < -1) {
      // ── CUTTING ──
      // Standard rate: 0.5–1% of bodyweight per week
      // 1kg fat = 7,700 kcal → 0.75kg/week loss = 5,775 kcal/week = 825 kcal/day deficit
      // Scale deficit based on how overweight the person is
      final double deficitPct;
      if      (kg >= 30) deficitPct = 0.35; // 35% deficit — very heavy, needs aggressive cut
      else if (kg >= 20) deficitPct = 0.30; // 30% deficit — significantly overweight
      else if (kg >= 10) deficitPct = 0.25; // 25% deficit — moderately overweight
      else if (kg >= 5)  deficitPct = 0.20; // 20% deficit — slightly overweight
      else               deficitPct = 0.15; // 15% deficit — small cut
      adjustment = 1.0 - deficitPct;
      final int kcalDeficit = (tdee * deficitPct).round();
      label = 'CUTTING ${kg.toStringAsFixed(0)}kg → ${(deficitPct*100).round()}% deficit (-$kcalDeficit kcal/day)';
    } else if (diff > 1) {
      // ── BULKING ──
      // Natural lifters can gain max 0.25kg muscle/week
      // Clean bulk = small surplus to minimise fat gain
      final double surplusPct;
      if      (kg >= 15) surplusPct = 0.10; // 10% surplus — needs significant mass
      else if (kg >= 5)  surplusPct = 0.07; // 7% surplus  — moderate bulk
      else               surplusPct = 0.05; // 5% surplus  — lean bulk
      adjustment = 1.0 + surplusPct;
      final int kcalSurplus = (tdee * surplusPct).round();
      label = 'BULKING ${kg.toStringAsFixed(0)}kg → ${(surplusPct*100).round()}% surplus (+$kcalSurplus kcal/day)';
    } else {
      // ── MAINTENANCE / RECOMPOSITION ──
      final String goal = userData.workoutGoal?.toLowerCase() ?? '';
      if (goal.contains('build') || goal.contains('muscle') || goal.contains('strength')) {
        adjustment = 1.05;
        label = 'RECOMP → 5% surplus for muscle building at same weight';
      } else {
        adjustment = 1.00;
        label = 'MAINTENANCE';
      }
    }

    // Safety floor: never below 1,400 kcal (male) or 1,200 kcal (female)
    final int floor  = isMale ? 1400 : 1200;
    final int result = (tdee * adjustment).round().clamp(floor, 4500);

    print('🎯 Goal: $label');
    print('   BMR: ${bmr.round()} kcal | TDEE: ${tdee.round()} kcal → Final: $result kcal');

    return result;
  }

  // ═══════════════════════════════════════════════════
  // STEP 2 — MACRO CALCULATOR
  // Protein first → Fat second → Carbs fill the rest
  // ═══════════════════════════════════════════════════
  Map<String, int> _calculateMacros(OnboardingData userData, int calories) {
    final double weight    = userData.weight?.toDouble()       ?? 70;
    final double targetWt  = userData.targetWeight?.toDouble() ?? weight;
    final bool   isCutting = (targetWt - weight) < -1;
    final bool   isBulking = (targetWt - weight) > 1;

    // ── 2A. Protein ──
    // Use target weight for cutting so protein isn't inflated by excess body fat
    final double proteinBase   = isCutting ? targetWt : weight;
    final double proteinPerKg  = isCutting ? 2.3       // high protein to preserve muscle
                                : isBulking ? 2.0       // moderate-high for building
                                :             1.8;      // maintenance
    final int protein    = (proteinBase * proteinPerKg).round();
    final int proteinCal = protein * 4;

    // ── 2B. Fat ──
    // 25% of total calories — enough for hormones, joints, fat-soluble vitamins
    final int fatCal = (calories * 0.25).round();
    final int fat    = (fatCal / 9).round();

    // ── 2C. Carbs = remaining calories ──
    final int carbCal = (calories - proteinCal - fatCal).clamp(0, 99999);
    final int carbs   = (carbCal / 4).round();

    print('📊 MACRO BREAKDOWN:');
    print('   Calories: $calories kcal');
    print('   Protein:  ${protein}g  ($proteinCal kcal / ${(proteinCal * 100 / calories).round()}%)');
    print('   Carbs:    ${carbs}g  ($carbCal kcal / ${(carbCal * 100 / calories).round()}%)');
    print('   Fat:      ${fat}g  ($fatCal kcal / ${(fatCal * 100 / calories).round()}%)');

    return {'calories': calories, 'protein': protein, 'carbs': carbs, 'fat': fat};
  }

  // ─────────────────────────────────────────────
  // BUDGET FOOD GUIDE
  // ─────────────────────────────────────────────
  Map<String, String> _getBudgetFoodGuide(String? budget) {
    switch (budget?.toLowerCase()) {
      case 'low':
        return {
          'label': 'LOW BUDGET',
          'allowed': 'PROTEINS: eggs, canned tuna, canned sardines, chicken thighs/legs, lean ground beef, lentils, chickpeas, black beans, kidney beans, tofu, milk, plain yogurt\n'
              'CARBS: white/brown rice, oats, bread, pasta, potatoes, sweet potatoes, bananas, apples, frozen vegetables, cabbage, carrots, onions\n'
              'FATS: egg yolks, sunflower oil, olive oil (small), peanut butter, mixed nuts (small amounts)',
          'forbidden': '⛔ FORBIDDEN (low budget): salmon, tuna steak, shrimp, avocado, greek yogurt, quinoa, chia seeds, protein bars, whey protein, almond milk, blueberries, ribeye steak, turkey breast, deli meats',
        };
      case 'high':
        return {
          'label': 'HIGH BUDGET',
          'allowed': 'PROTEINS: salmon, tuna steak, shrimp, chicken breast, turkey breast, lean steak, eggs, greek yogurt, whey protein, cottage cheese, tofu, tempeh\n'
              'CARBS: quinoa, sweet potatoes, brown rice, whole grain pasta, oats, fresh berries, all fresh vegetables, whole grain/sourdough bread\n'
              'FATS: avocado, extra virgin olive oil, mixed nuts, almond butter, chia seeds, flaxseeds, coconut oil, tahini',
          'forbidden': 'No restrictions — use premium quality ingredients',
        };
      default: // medium
        return {
          'label': 'MEDIUM BUDGET',
          'allowed': 'PROTEINS: chicken breast/thighs, eggs, canned tuna, lean ground beef, cottage cheese, plain yogurt, lentils, chickpeas, tofu\n'
              'CARBS: rice, oats, pasta, bread, potatoes, sweet potatoes, bananas, apples, oranges, seasonal/frozen vegetables, tomatoes, cucumber\n'
              'FATS: eggs, olive oil, peanut butter, sunflower seeds, small amounts of nuts',
          'forbidden': '⛔ AVOID (medium budget): salmon, shrimp, avocado daily, quinoa daily, fresh berries daily, protein bars, deli meats, greek yogurt daily, sirloin/ribeye steak',
        };
    }
  }

  // ─────────────────────────────────────────────
  // PROMPT BUILDER
  // ─────────────────────────────────────────────
  String _buildWeeklyPlanPrompt(OnboardingData userData) {
    final int calories     = _calculateBaseCalories(userData);
    final macros           = _calculateMacros(userData, calories);
    final int protein      = macros['protein']!;
    final int carbs        = macros['carbs']!;
    final int fat          = macros['fat']!;
    final int mealsPerDay  = userData.mealsPerDay ?? 3;
    final budgetGuide      = _getBudgetFoodGuide(userData.budget);

    print('   Meals per day: $mealsPerDay');
    print('   Budget: ${budgetGuide['label']}\n');

    

    return """
You are a professional sports nutritionist. Generate a precise diet and workout plan.

══ USER ══
Age: ${userData.age} | Gender: ${userData.gender} | Height: ${userData.height}cm
Weight: ${userData.weight}kg → Target: ${userData.targetWeight}kg
Goal: ${userData.workoutGoal} | Training: ${userData.trainingDays}x/week at ${userData.trainingLocation}
Diet: ${userData.dietPreference ?? 'Normal'} | Allergies: ${userData.allergies?.join(', ') ?? 'None'}
Budget: ${budgetGuide['label']} | Meals/day: $mealsPerDay

══ MANDATORY DAILY TARGETS ══
Calories : $calories kcal  ← The SUM of all meal calories MUST equal this
Protein  : ${protein}g
Carbs    : ${carbs}g
Fat      : ${fat}g

VERIFICATION RULE: Before writing [DAILY_TOTAL], manually add up all meal calories.
If the sum ≠ $calories kcal, increase portion sizes and recalculate.

══ PORTION SIZING GUIDE ══
To reach $calories kcal across $mealsPerDay meals, use large portions:
- Rice/pasta: 200-350g cooked per meal (260-450 kcal)
- Chicken breast: 200-300g per meal (220-330 kcal)
- Eggs: 3-5 eggs per meal (210-350 kcal)
- Oats: 80-120g dry + 250-300ml milk (ALWAYS cooked or soaked in milk, NEVER dry alone)
- Peanut butter: 30-50g (190-310 kcal) — ONLY in breakfast or snacks
- Olive oil / cooking oil: 10-15ml per meal adds 90-135 kcal
Do NOT use tiny amounts. Scale up until each meal hits its required calories.

══ FOOD COMBINATION RULES (STRICTLY ENFORCED) ══
BREAKFAST ideas: oatmeal cooked in milk + eggs, scrambled eggs + toast + milk, yogurt + oats + fruit
LUNCH ideas: chicken/beef/tuna + rice or pasta + cooked vegetables
DINNER ideas: meat or fish + rice or pasta or potatoes + vegetables cooked in olive oil
SNACK ideas: cottage cheese + fruit, boiled eggs + bread, peanut butter + banana, yogurt + oats

⛔ FORBIDDEN COMBINATIONS — THESE MAKE THE RESPONSE INVALID:
- Peanut butter in lunch or dinner (ONLY allowed in breakfast or snacks)
- Oats without milk — oats MUST always be cooked or soaked in milk
- Peanut butter mixed with tomato sauce, pasta sauce, rice, or any savoury dish
- Sweet ingredients (honey, jam, banana) mixed directly into a chicken or meat dish
- Nuts or nut butter added into pasta or rice dishes
- Cottage cheese or yogurt as the main protein source in dinner
Every meal MUST make real culinary sense and taste good in real life.

══ BUDGET RULES (STRICTLY ENFORCED) ══
${budgetGuide['allowed']}
${budgetGuide['forbidden']}

══ DIET PREFERENCE ══
${userData.dietPreference == 'Vegetarian' ? '⚠️ NO MEAT OR FISH. Use eggs, tofu, lentils, beans, dairy as protein sources.' : ''}
${userData.dietPreference == 'Keto' ? '⚠️ KETO: Max 30g carbs/day. Use fats and protein to fill remaining calories.' : ''}
${userData.dietPreference == 'High Protein' ? '⚠️ HIGH PROTEIN: Prioritise protein. Add protein-dense foods to every meal.' : ''}
${userData.dietPreference == 'Low Carb' ? '⚠️ LOW CARB: Max 100g carbs/day. Replace carbs with fats.' : ''}

══ OUTPUT FORMAT ══
===DIET PLAN===
[BREAKFAST]
Name: [meal name]
Portions:
- [food]: [amount] → [kcal]
- [food]: [amount] → [kcal]
- [food]: [amount] → [kcal]
Calories: [total for this meal]
Protein: [g]
Carbs: [g]
Fat: [g]

[LUNCH]
Name: [meal name]
Portions:
- [food]: [amount] → [kcal]
- [food]: [amount] → [kcal]
- [food]: [amount] → [kcal]
Calories: [total for this meal]
Protein: [g]
Carbs: [g]
Fat: [g]

Calories: [total for this meal]
Protein: [g]
Carbs: [g]
Fat: [g]''' : ''}

${mealsPerDay >= 5 ? '''[MEAL 5]
Name: [meal name]
Portions:
- [food]: [amount] → [kcal]
- [food]: [amount] → [kcal]
Calories: [total for this meal]
Protein: [g]
Carbs: [g]
Fat: [g]''' : ''}

[DAILY_TOTAL]
Calories: $calories
Protein: ${protein}g
Carbs: ${carbs}g
Fat: ${fat}g

===WORKOUT PLAN===
[DAY 1 - MUSCLE GROUP]
Muscles: [targets]
Duration: [min]

Exercises:
1. [Exercise Name]: [sets] sets, [reps] reps
   Video URL: https://www.youtube.com/results?search_query=[exercise+name]+how+to+do+proper+form

[Repeat for ${userData.trainingDays} workout days]

WORKOUT RULES:
- ${userData.trainingLocation == 'Gym' ? 'Use gym equipment (barbells, dumbbells, machines, cables)' : 'Bodyweight exercises only — no gym required'}
- 4–6 exercises per day
- Video URL is MANDATORY for every exercise

START NOW WITH ===DIET PLAN===:
""";
  }

  // ─────────────────────────────────────────────
  // GROQ API CALL
  // ─────────────────────────────────────────────
  Future<String> _callGroqAPI(String prompt) async {
    print('📡 Calling Groq AI API...');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a professional sports nutritionist and certified personal trainer. '
                'You always generate mathematically accurate meal plans where meal calories sum exactly to the daily target. '
                'You never use forbidden foods for the specified budget. '
                'You always include Video URLs for every exercise.'
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.3, // Lower = more precise, less creative
        'max_tokens': 8000,
        'stream': false,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ API call successful');
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Groq API Error: ${response.statusCode} - ${response.body}');
    }
  }

  // ─────────────────────────────────────────────
  // RESPONSE PARSER
  // ─────────────────────────────────────────────
  Map<String, String> _parsePlans(String response) {
    print('🔍 Parsing AI response...');
    print('📄 Response length: ${response.length} characters');

    final dietMarker    = RegExp(r'===\s*DIET\s*PLAN\s*===',    caseSensitive: false);
    final workoutMarker = RegExp(r'===\s*WORKOUT\s*PLAN\s*===', caseSensitive: false);

    final dietMatch    = dietMarker.firstMatch(response);
    final workoutMatch = workoutMarker.firstMatch(response);

    if (dietMatch != null && workoutMatch != null) {
      print('✅ Found both markers!');
      final dietContent    = response.substring(dietMatch.end,    workoutMatch.start).trim();
      final workoutContent = response.substring(workoutMatch.end).trim();

      print('📊 Diet plan:    ${dietContent.length} chars');
      print('📊 Workout plan: ${workoutContent.length} chars');

      return {
        'diet':    dietContent.isEmpty    ? 'Empty diet plan'    : dietContent,
        'workout': workoutContent.isEmpty ? 'Empty workout plan' : workoutContent,
      };
    }

    // Fallback
    final altDiet    = RegExp(r'DIET\s*PLAN',    caseSensitive: false).firstMatch(response);
    final altWorkout = RegExp(r'WORKOUT\s*PLAN', caseSensitive: false).firstMatch(response);

    if (altDiet != null && altWorkout != null) {
      print('✅ Found alternative markers!');
      return {
        'diet':    response.substring(altDiet.end,    altWorkout.start).trim(),
        'workout': response.substring(altWorkout.end).trim(),
      };
    }

    print('⚠️ Markers not found — returning raw response');
    return {
      'diet':    response,
      'workout': 'Could not parse workout plan',
    };
  }
}