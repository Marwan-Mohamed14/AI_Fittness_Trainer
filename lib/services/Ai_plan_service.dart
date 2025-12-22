import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_personal_trainer/models/onboarding_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class AiPlanService {
  final String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';  
   final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
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
      // Build the prompt
      final prompt = _buildWeeklyPlanPrompt(userData);
      
      // Call Groq AI
      final response = await _callGroqAPI(prompt);
      
      // Parse response into diet and workout sections
      final plans = _parsePlans(response);
      
      print('\n✅ Plans generated successfully!');
      print('=' * 80);
      print('📋 DIET PLAN (7 days):');
      print(plans['diet']);
      print('\n' + '-' * 80);
      print('💪 WORKOUT PLAN (${userData.trainingDays} days):');
      print(plans['workout']);
      print('=' * 80 + '\n');
      
      return plans;
    } catch (e) {
      print('❌ Error generating plans: $e');
      rethrow;
    }
  }

  /// FUNCTION 2: Build the AI prompt
  /// WHY: This creates a detailed instruction for the AI based on user data
String _buildWeeklyPlanPrompt(OnboardingData userData) {
  // Calculate daily calorie needs based on user data
  final baseCalories = _calculateBaseCalories(userData);
  final mealsPerDay = userData.mealsPerDay ?? 3;
  
  return '''
Create a personalized ${userData.trainingDays}-day fitness plan for a ${userData.age}-year-old ${userData.gender}.

USER PROFILE:
- Current Weight: ${userData.weight}kg
- Target Weight: ${userData.targetWeight}kg
- Goal: ${userData.workoutGoal}
- Experience Level: ${userData.workoutLevel}
- Training: ${userData.trainingDays} days/week at ${userData.trainingLocation}
- Diet Preference: ${userData.dietPreference ?? 'Normal'}
- Meals per day: $mealsPerDay
- Budget: ${userData.budget ?? 'Medium'}
- Allergies/Restrictions: ${userData.allergies?.join(', ') ?? 'None'}

IMPORTANT FORMAT REQUIREMENTS (MUST FOLLOW EXACTLY):
===DIET PLAN===
${_generateMealFormat(mealsPerDay)}

[DAILY_TOTAL]
Calories: [number] kcal
Protein: [number]g
Carbs: [number]g
Fat: [number]g

===WORKOUT PLAN===
[Day 1]
[Day 2]
... (continue for all ${userData.trainingDays} days)

CRITICAL RULES:
1. VARIETY IS ESSENTIAL: Use completely different foods each day. Do NOT repeat the same meals.
2. RESPECT DIET PREFERENCE: If ${userData.dietPreference ?? 'Normal'}, create meals that match this preference.
3. RESPECT ALLERGIES: Absolutely avoid ${userData.allergies?.join(', ') ?? 'nothing - user has no allergies'}.
4. BUDGET AWARENESS: Use ingredients appropriate for ${userData.budget ?? 'Medium'} budget.
5. MEAL DISTRIBUTION: User wants EXACTLY $mealsPerDay meals per day. You MUST create exactly $mealsPerDay meal sections. Use meal names like: Breakfast, Lunch, Dinner, Snack, or Meal 1, Meal 2, etc. based on the number of meals.
6. CALORIE TARGET: Aim for approximately $baseCalories calories per day to help reach target weight of ${userData.targetWeight}kg.
7. WORKOUT LOCATION: ${userData.trainingLocation == 'Gym' ? 'Use gym equipment (machines, free weights, cables)' : 'Use bodyweight exercises and minimal equipment (dumbbells, resistance bands)'}.
8. BE CREATIVE: Use diverse proteins (fish, lean meats, legumes, tofu, etc.), varied carbs (rice, quinoa, sweet potatoes, oats, etc.), and healthy fats (avocado, nuts, olive oil, etc.).
9. NO REPETITION: Each day should have unique meal combinations. Vary cooking methods (grilled, baked, steamed, raw, etc.).

START YOUR RESPONSE WITH "===DIET PLAN===":
''';
}

  /// Generate meal format based on number of meals
  String _generateMealFormat(int mealsPerDay) {
    final mealNames = ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK', 'MEAL 5'];
    final format = StringBuffer();
    
    for (int i = 0; i < mealsPerDay; i++) {
      final mealName = i < mealNames.length ? mealNames[i] : 'MEAL ${i + 1}';
      format.writeln('[$mealName]');
      format.writeln('Name: [creative, varied dish name based on diet preference]');
      format.writeln('Portions: [specific amounts and ingredients - list each food item separately with portion sizes]');
      format.writeln('Calories: [number] kcal');
      format.writeln('Protein: [number]g');
      format.writeln('Carbs: [number]g');
      format.writeln('Fat: [number]g');
      if (i < mealsPerDay - 1) format.writeln('');
    }
    
    return format.toString();
  }

  /// Calculate base daily calories based on user profile
  int _calculateBaseCalories(OnboardingData userData) {
    // Simple BMR calculation (Mifflin-St Jeor Equation approximation)
    final age = userData.age ?? 30;
    final weight = userData.weight ?? 70;
    final height = userData.height ?? 170;
    final isMale = userData.gender?.toLowerCase() == 'male';
    
    // Base BMR
    double bmr = (10 * weight) + (6.25 * height) - (5 * age) + (isMale ? 5 : -161);
    
    // Activity multiplier based on training days
    double activityMultiplier = 1.2; // Sedentary base
    if (userData.trainingDays != null) {
      if (userData.trainingDays! >= 5) {
        activityMultiplier = 1.725; // Very active
      } else if (userData.trainingDays! >= 3) {
        activityMultiplier = 1.55; // Moderately active
      } else if (userData.trainingDays! >= 1) {
        activityMultiplier = 1.375; // Lightly active
      }
    }
    
    // Adjust for goal
    double goalAdjustment = 1.0;
    final goal = userData.workoutGoal?.toLowerCase() ?? '';
    if (goal.contains('lose')) {
      goalAdjustment = 0.85; // 15% deficit for weight loss
    } else if (goal.contains('build') || goal.contains('gain')) {
      goalAdjustment = 1.15; // 15% surplus for muscle gain
    }
    
    final dailyCalories = (bmr * activityMultiplier * goalAdjustment).round();
    
    // Ensure reasonable range
    return dailyCalories.clamp(1200, 4000);
  }
  /// FUNCTION 3: Call Groq AI API
  /// WHY: This sends the prompt to Groq and gets the AI response
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
            'content': 'You are an expert fitness coach and nutritionist. Create detailed, practical plans.'
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': 0.5,
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

  /// FUNCTION 4: Parse AI response into separate plans
  /// WHY: The AI returns both plans together, we need to split them
  Map<String, String> _parsePlans(String response) {
  print('🔍 Parsing AI response...');
  print('📄 Response length: ${response.length} characters');
  
  // Find the positions of the markers
  final dietMarker = RegExp(r'===\s*DIET\s*PLAN\s*===', caseSensitive: false);
  final workoutMarker = RegExp(r'===\s*WORKOUT\s*PLAN\s*===', caseSensitive: false);
  
  final dietMarkerMatch = dietMarker.firstMatch(response);
  final workoutMarkerMatch = workoutMarker.firstMatch(response);
  
  if (dietMarkerMatch != null && workoutMarkerMatch != null) {
    print('✅ Found both markers!');
    
    // Extract diet plan (from DIET PLAN marker to WORKOUT PLAN marker)
    final dietStart = dietMarkerMatch.end;
    final workoutStart = workoutMarkerMatch.start;
    final dietContent = response.substring(dietStart, workoutStart).trim();
    
    // Extract workout plan (from WORKOUT PLAN marker to end)
    final workoutContent = response.substring(workoutMarkerMatch.end).trim();
    
    print('📊 Diet plan extracted: ${dietContent.length} characters');
    print('📊 Workout plan extracted: ${workoutContent.length} characters');
    print('📄 Diet plan preview (first 300 chars): ${dietContent.length > 300 ? dietContent.substring(0, 300) + "..." : dietContent}');
    print('📄 Workout plan preview (first 300 chars): ${workoutContent.length > 300 ? workoutContent.substring(0, 300) + "..." : workoutContent}');
    
    return {
      'diet': dietContent.isEmpty ? 'Empty diet plan' : dietContent,
      'workout': workoutContent.isEmpty ? 'Empty workout plan' : workoutContent,
    };
  }
  
  // Fallback: Try alternative markers
  final altDietMarker = RegExp(r'DIET\s*PLAN', caseSensitive: false);
  final altWorkoutMarker = RegExp(r'WORKOUT\s*PLAN', caseSensitive: false);
  
  final altDietMatch = altDietMarker.firstMatch(response);
  final altWorkoutMatch = altWorkoutMarker.firstMatch(response);
  
  if (altDietMatch != null && altWorkoutMatch != null) {
    print('✅ Found alternative markers!');
    final dietStart = altDietMatch.end;
    final workoutStart = altWorkoutMatch.start;
    final dietContent = response.substring(dietStart, workoutStart).trim();
    final workoutContent = response.substring(altWorkoutMatch.end).trim();
    
    return {
      'diet': dietContent.isEmpty ? 'Empty diet plan' : dietContent,
      'workout': workoutContent.isEmpty ? 'Empty workout plan' : workoutContent,
    };
  }
  
  print('⚠️ Markers not found!');
  print('📄 Response preview (first 500 chars): ${response.length > 500 ? response.substring(0, 500) + "..." : response}');
  
  // If no markers found, try to split by common patterns
  // This is a fallback - ideally the AI should always use the markers
  return {
    'diet': response,
    'workout': 'Could not separate workout plan - markers not found in response',
  };
}
}