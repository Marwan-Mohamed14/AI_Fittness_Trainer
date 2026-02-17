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

  // ═══════════════════════════════════════════════════
  // STEP 1 — CALORIE CALCULATOR
  // Formula: Mifflin-St Jeor BMR × Activity × Goal
  // ═══════════════════════════════════════════════════
  int _calculateBaseCalories(OnboardingData userData) {
    final double weight       = userData.weight?.toDouble()       ?? 70;
    final double targetWeight = userData.targetWeight?.toDouble() ?? weight;
    final double height       = userData.height?.toDouble()       ?? 175;
    final int    age          = userData.age                      ?? 25;
    final bool   isMale       = userData.gender?.toLowerCase()    == 'male';
    final int    days         = userData.trainingDays             ?? 0;

    final double bmi = weight / ((height / 100) * (height / 100));
    final double bmrWeight;
    if (bmi > 30) {
      final double idealWeight = isMale
          ? 50.0 + 2.3 * ((height - 152.4) / 2.54)
          : 45.5 + 2.3 * ((height - 152.4) / 2.54);
      bmrWeight = idealWeight + 0.25 * (weight - idealWeight);
      print('   BMI: ${bmi.toStringAsFixed(1)} → Obese, adjusted BMR weight: ${bmrWeight.toStringAsFixed(1)}kg');
    } else {
      bmrWeight = weight;
      print('   BMI: ${bmi.toStringAsFixed(1)} → Normal, using actual weight: ${weight}kg');
    }

    final double bmr = (10 * bmrWeight) + (6.25 * height) - (5 * age) + (isMale ? 5 : -161);

    final double activity;
    if      (days >= 6) activity = 1.90;
    else if (days >= 5) activity = 1.725;
    else if (days >= 3) activity = 1.55;
    else if (days >= 1) activity = 1.375;
    else                activity = 1.20;
    final double tdee = bmr * activity;

    final double diff = targetWeight - weight;
    final double kg   = diff.abs();
    final double adjustment;
    final String label;

    if (diff < -1) {
      final double deficitPct;
      if      (kg >= 30) deficitPct = 0.35;
      else if (kg >= 20) deficitPct = 0.30;
      else if (kg >= 10) deficitPct = 0.25;
      else if (kg >= 5)  deficitPct = 0.20;
      else               deficitPct = 0.15;
      adjustment = 1.0 - deficitPct;
      final int kcalDeficit = (tdee * deficitPct).round();
      label = 'CUTTING ${kg.toStringAsFixed(0)}kg → ${(deficitPct*100).round()}% deficit (-$kcalDeficit kcal/day)';
    } else if (diff > 1) {
      final double surplusPct;
      if      (kg >= 15) surplusPct = 0.10;
      else if (kg >= 5)  surplusPct = 0.07;
      else               surplusPct = 0.05;
      adjustment = 1.0 + surplusPct;
      final int kcalSurplus = (tdee * surplusPct).round();
      label = 'BULKING ${kg.toStringAsFixed(0)}kg → ${(surplusPct*100).round()}% surplus (+$kcalSurplus kcal/day)';
    } else {
      final String goal = userData.workoutGoal?.toLowerCase() ?? '';
      if (goal.contains('build') || goal.contains('muscle') || goal.contains('strength')) {
        adjustment = 1.05;
        label = 'RECOMP → 5% surplus for muscle building at same weight';
      } else {
        adjustment = 1.00;
        label = 'MAINTENANCE';
      }
    }

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
    final double weight   = userData.weight?.toDouble()       ?? 70;
    final double targetWt = userData.targetWeight?.toDouble() ?? weight;
    final bool isCutting  = (targetWt - weight) < -1;
    final bool isBulking  = (targetWt - weight) > 1;

    final double proteinBase  = isCutting ? targetWt : weight;
    final double proteinPerKg = isCutting ? 2.3 : isBulking ? 2.0 : 1.8;
    final int protein    = (proteinBase * proteinPerKg).round();
    final int proteinCal = protein * 4;
    final int fatCal     = (calories * 0.25).round();
    final int fat        = (fatCal / 9).round();
    final int carbCal    = (calories - proteinCal - fatCal).clamp(0, 99999);
    final int carbs      = (carbCal / 4).round();

    print('📊 MACRO BREAKDOWN:');
    print('   Calories: $calories kcal');
    print('   Protein:  ${protein}g  ($proteinCal kcal / ${(proteinCal * 100 / calories).round()}%)');
    print('   Carbs:    ${carbs}g  ($carbCal kcal / ${(carbCal * 100 / calories).round()}%)');
    print('   Fat:      ${fat}g  ($fatCal kcal / ${(fatCal * 100 / calories).round()}%)');
    return {'calories': calories, 'protein': protein, 'carbs': carbs, 'fat': fat};
  }

  // ═══════════════════════════════════════════════════
  // BUDGET FOOD GUIDE
  // ═══════════════════════════════════════════════════
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
      default:
        return {
          'label': 'MEDIUM BUDGET',
          'allowed': 'PROTEINS: chicken breast/thighs, eggs, canned tuna, lean ground beef, cottage cheese, plain yogurt, lentils, chickpeas, tofu\n'
              'CARBS: rice, oats, pasta, bread, potatoes, sweet potatoes, bananas, apples, oranges, seasonal/frozen vegetables, tomatoes, cucumber\n'
              'FATS: eggs, olive oil, peanut butter, sunflower seeds, small amounts of nuts',
          'forbidden': '⛔ AVOID (medium budget): salmon, shrimp, avocado daily, quinoa daily, fresh berries daily, protein bars, deli meats, greek yogurt daily, sirloin/ribeye steak',
        };
    }
  }

  // ═══════════════════════════════════════════════════
  // WORKOUT SPLIT SELECTOR
  // Returns split name, structure hint, and sets/reps guide
  // ═══════════════════════════════════════════════════
  Map<String, String> _getWorkoutSplit(OnboardingData userData) {
    final int    days  = userData.trainingDays ?? 3;
    final String level = userData.workoutLevel?.toLowerCase() ?? 'beginner';
    final bool   isAdv = level == 'advanced';

    final String setsReps = isAdv
        ? '4-5 sets/6-12 reps compounds, 3-4 sets/8-15 reps isolation'
        : level == 'intermediate'
            ? '3-4 sets/8-12 reps compounds, 3 sets/10-15 reps isolation'
            : '3 sets/10-15 reps compounds, 2-3 sets/12-15 reps isolation';

    final String name;
    final String structure;

    if (days == 1) {
      name = 'Full Body';
      structure = 'DAY 1 - FULL BODY (7-8 ex): flat bench[chest mid], pull-up[back width], squat[quads], overhead press[shoulder front], lateral raise[shoulder side], barbell curl[biceps], tricep pushdown[triceps], hanging leg raise[abs], romanian deadlift[hamstrings]';
    } else if (days == 2) {
      name = 'Upper / Lower Split';
      structure =
          'DAY 1 - UPPER BODY (8 ex): incline press[chest upper], flat bench[chest mid], lat pulldown[back width], barbell row[back thickness], overhead press[shoulder front], lateral raise[shoulder side], hammer curl[biceps long head], skull crusher[triceps long head], plank[abs]\n'
          'DAY 2 - LOWER BODY (7 ex): squat[quads], leg extension[quads iso], romanian deadlift[hamstrings], leg curl[hamstrings iso], hip thrust[glutes], calf raise, reverse crunch[abs]';
    } else if (days == 3) {
      name = 'Push / Pull / Legs';
      structure =
          'DAY 1 - PUSH (7 ex): flat bench[chest lower], incline press[chest upper], cable fly[chest iso], overhead press[shoulder front], lateral raise[shoulder side], overhead tricep ext[triceps long head], cable pushdown[triceps lateral head]\n'
          'DAY 2 - PULL (7 ex): pull-up[back width], barbell row[back thickness], seated cable row[back lower], face pull[rear delt], incline curl[biceps long head], preacher curl[biceps short head], hanging leg raise[abs]\n'
          'DAY 3 - LEGS (8 ex): squat[quads], leg extension[quads iso], romanian deadlift[hamstrings], leg curl[hamstrings iso], hip thrust[glutes], calf raise, hanging leg raise[abs lower], plank[abs core]';
    } else if (days == 4) {
      name = 'Bro Split';
      structure =
          'DAY 1 - CHEST + TRICEPS (6 ex): flat bench[chest lower], incline press[chest upper], cable fly[chest iso], skull crusher[triceps long head], cable pushdown[triceps lateral head], close-grip bench[triceps medial]\n'
          'DAY 2 - BACK + BICEPS (6 ex): pull-up[back width], barbell row[back thickness], seated row[back lower], incline curl[biceps long head], preacher curl[biceps short head], face pull[rear delt]\n'
          'DAY 3 - LEGS (7 ex): squat[quads], leg extension[quads iso], romanian deadlift[hamstrings], leg curl[hamstrings iso], hip thrust[glutes], calf raise, hanging leg raise[abs]\n'
          'DAY 4 - SHOULDERS + ABS (6 ex): overhead press[shoulder front], lateral raise[shoulder side], rear delt fly[shoulder rear], cable crunch[abs upper], hanging leg raise[abs lower], russian twist[abs obliques]';
    } else if (days == 5 && !isAdv) {
      name = 'Chest+Tri / Back+Bi / Legs / Shoulders / Arms+Abs';
      structure =
          'DAY 1 - CHEST + TRICEPS (6 ex): flat bench[chest lower], incline press[chest upper], cable fly[chest iso], skull crusher[triceps long head], cable pushdown[triceps lateral head], close-grip bench[triceps medial]\n'
          'DAY 2 - BACK + BICEPS (6 ex): pull-up[back width], barbell row[back thickness], seated row[back lower], barbell curl[biceps long head], preacher curl[biceps short head], face pull[rear delt]\n'
          'DAY 3 - LEGS (7 ex): squat[quads], leg extension[quads iso], romanian deadlift[hamstrings], leg curl[hamstrings iso], hip thrust[glutes], calf raise, hanging leg raise[abs]\n'
          'DAY 4 - SHOULDERS (6 ex): overhead press[shoulder front], lateral raise[shoulder side], rear delt fly[shoulder rear], shrugs[traps], arnold press[shoulder iso], plank[abs]\n'
          'DAY 5 - ARMS + ABS (6 ex): barbell curl[biceps long head], preacher curl[biceps short head], hammer curl[brachialis], overhead tricep ext[triceps long head], cable pushdown[triceps lateral head], hanging leg raise + cable crunch[abs]';
    } else if (days == 5 && isAdv) {
      name = 'Arnold Split';
      structure =
          'PRINCIPLE: Each muscle group trained TWICE with DIFFERENT exercises\n'
          'DAY 1 - CHEST + BACK (7-8 ex): flat bench[chest lower], pull-up[back width], incline DB press[chest upper], barbell row[back thickness], cable fly[chest iso], seated row[back lower], face pull[rear delt], plank[abs]\n'
          'DAY 2 - SHOULDERS + ARMS (7-8 ex): overhead press[shoulder front], lateral raise[shoulder side], rear delt fly, barbell curl[biceps long head], preacher curl[biceps short head], skull crusher[triceps long head], cable pushdown[triceps lateral head], cable crunch[abs]\n'
          'DAY 3 - LEGS (7 ex): squat, leg extension, romanian deadlift, leg curl, hip thrust, calf raise, hanging leg raise[abs]\n'
          'DAY 4 - CHEST + BACK (7-8 ex — DIFFERENT from Day 1): incline barbell[chest upper], close grip pulldown[back width], decline DB[chest lower], single-arm row[back thickness], DB fly[chest iso], straight-arm pulldown[back lower], reverse pec deck[rear delt], ab wheel[abs]\n'
          'DAY 5 - SHOULDERS + ARMS (7-8 ex — DIFFERENT from Day 2): arnold press[shoulder front], cable lateral raise[shoulder side], face pull[rear delt], hammer curl[biceps long head], concentration curl[biceps short head], french press[triceps long head], tricep dips[triceps lateral head], bicycle crunch[abs]';
    } else if (days == 6 && !isAdv) {
      name = 'Bro Split + Cardio Day';
      structure =
          'DAY 1 - CHEST + TRICEPS (6 ex): flat bench[chest lower], incline press[chest upper], cable fly[chest iso], skull crusher[triceps long head], cable pushdown[triceps lateral head], close-grip bench[triceps medial]\n'
          'DAY 2 - BACK + BICEPS (6 ex): pull-up[back width], barbell row[back thickness], seated row[back lower], barbell curl[biceps long head], preacher curl[biceps short head], face pull[rear delt]\n'
          'DAY 3 - LEGS (7 ex): squat[quads], leg extension[quads iso], romanian deadlift[hamstrings], leg curl[hamstrings iso], hip thrust[glutes], calf raise, hanging leg raise[abs]\n'
          'DAY 4 - SHOULDERS + ABS (6 ex): overhead press[shoulder front], lateral raise[shoulder side], rear delt fly[shoulder rear], cable crunch[abs upper], hanging leg raise[abs lower], russian twist[abs obliques]\n'
          'DAY 5 - FULL ARMS (6 ex): barbell curl[biceps long head], preacher curl[biceps short head], hammer curl[brachialis], overhead tricep ext[triceps long head], cable pushdown[triceps lateral head], hanging leg raise + cable crunch[abs]\n'
          'DAY 6 - CARDIO + ABS (5 ex): 20-30min treadmill/elliptical/bike[cardio], cable crunch[abs upper], hanging leg raise[abs lower], russian twist[abs obliques], plank[abs core]';
    } else {
      name = 'Arnold Split + Cardio Day';
      structure =
          'PRINCIPLE: Each muscle trained TWICE with DIFFERENT exercises + Cardio Day 6\n'
          'DAY 1 - CHEST + BACK (7-8 ex): flat bench[chest lower], pull-up[back width], incline DB press[chest upper], barbell row[back thickness], cable fly[chest iso], seated row[back lower], face pull[rear delt], plank[abs]\n'
          'DAY 2 - SHOULDERS + ARMS (7-8 ex): overhead press[shoulder front], lateral raise[shoulder side], rear delt fly, barbell curl[biceps long head], preacher curl[biceps short head], skull crusher[triceps long head], cable pushdown[triceps lateral head], cable crunch[abs]\n'
          'DAY 3 - LEGS (7 ex): squat, leg extension, romanian deadlift, leg curl, hip thrust, calf raise, hanging leg raise[abs]\n'
          'DAY 4 - CHEST + BACK (7-8 ex — DIFFERENT from Day 1): incline barbell[chest upper], close grip pulldown[back width], decline DB[chest lower], single-arm row[back thickness], DB fly[chest iso], straight-arm pulldown[back lower], reverse pec deck[rear delt], ab wheel[abs]\n'
          'DAY 5 - SHOULDERS + ARMS (7-8 ex — DIFFERENT from Day 2): arnold press[shoulder front], cable lateral raise[shoulder side], face pull[rear delt], hammer curl[biceps long head], concentration curl[biceps short head], french press[triceps long head], tricep dips[triceps lateral head], bicycle crunch[abs]\n'
          'DAY 6 - CARDIO + ABS (5 ex): 20-30min cardio[cardio], cable crunch[abs upper], hanging leg raise[abs lower], bicycle crunch[abs obliques], ab wheel[abs core]';
    }

    return {'name': name, 'structure': structure, 'setsReps': setsReps};
  }

  // ═══════════════════════════════════════════════════
  // PROMPT BUILDER
  // ═══════════════════════════════════════════════════
  String _buildWeeklyPlanPrompt(OnboardingData userData) {
    final int calories    = _calculateBaseCalories(userData);
    final macros          = _calculateMacros(userData, calories);
    final int protein     = macros['protein']!;
    final int carbs       = macros['carbs']!;
    final int fat         = macros['fat']!;
    final int mealsPerDay = userData.mealsPerDay ?? 3;
    final budgetGuide     = _getBudgetFoodGuide(userData.budget);
    final split           = _getWorkoutSplit(userData);
    final bool isGym      = (userData.trainingLocation?.toLowerCase() ?? 'gym') == 'gym';

    print('   Meals per day: $mealsPerDay');
    print('   Budget: ${budgetGuide['label']}');
    print('   Split: ${split['name']}\n');

    return """
You are a professional sports nutritionist and certified personal trainer. Generate a precise diet and workout plan.

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
${userData.dietPreference == 'Vegetarian' ? '⚠️ NO MEAT OR FISH. Use eggs, tofu, lentils, beans, dairy as protein sources.' : ''}${userData.dietPreference == 'Keto' ? '⚠️ KETO: Max 30g carbs/day. Use fats and protein to fill remaining calories.' : ''}${userData.dietPreference == 'High Protein' ? '⚠️ HIGH PROTEIN: Prioritise protein. Add protein-dense foods to every meal.' : ''}${userData.dietPreference == 'Low Carb' ? '⚠️ LOW CARB: Max 100g carbs/day. Replace carbs with fats.' : ''}

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

[DINNER]
Name: [meal name]
Portions:
- [food]: [amount] → [kcal]
- [food]: [amount] → [kcal]
- [food]: [amount] → [kcal]
Calories: [total for this meal]
Protein: [g]
Carbs: [g]
Fat: [g]
${mealsPerDay >= 4 ? '''
[SNACK]
Name: [meal name]
Portions:
- [food]: [amount] → [kcal]
- [food]: [amount] → [kcal]
Calories: [total for this meal]
Protein: [g]
Carbs: [g]
Fat: [g]''' : ''}
${mealsPerDay >= 5 ? '''
[MEAL 5]
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
SPLIT: ${split['name']} | LEVEL: ${userData.workoutLevel ?? 'Beginner'} | SETS/REPS: ${split['setsReps']}
EQUIPMENT: ${isGym ? 'Gym (barbells, dumbbells, cables, machines)' : 'Bodyweight only'}
STRUCTURE TO FOLLOW EXACTLY:
${split['structure']}

STRICT RULES:
- Generate ALL ${userData.trainingDays} days following the structure above
- MINIMUM 5 exercises per day, TARGET 6, MAX 8
- Never 2 exercises for the same muscle region in one day
- Biceps: always mix long head + short head | Triceps: mix long head + lateral head
- Shoulders: always include front delt + side delt + rear delt
- Every exercise MUST have a Video URL on the very next line

FORMAT FOR EVERY DAY:
[DAY 1 - MUSCLE GROUP NAME]
Muscles: [targets]
Duration: [X] Min

Exercises:
1. [Exercise Name]: [sets] sets, [reps] reps
   Video URL: https://www.youtube.com/results?search_query=[exercise+name]+how+to+do+proper+form

2. [Exercise Name]: [sets] sets, [reps] reps
   Video URL: https://www.youtube.com/results?search_query=[exercise+name]+how+to+do+proper+form

[Repeat for remaining days]

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
        'temperature': 0.3,
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