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
      final prompt = _buildWeeklyPlanPrompt(userData);
      
      
      final response = await _callGroqAPI(prompt);
      
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

  
String _buildWeeklyPlanPrompt(OnboardingData userData) {
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
For each day, format as follows:
[DAY 1 - MUSCLE GROUP]
Muscles: [target muscles]
Duration: [estimated time] Min

Exercises:
1. [Exercise Name]: [Sets] sets, [Reps] reps
   Video URL: [MUST provide a YouTube search URL in this format:
   https://www.youtube.com/results?search_query=exercise+name+how+to+do+proper+form
   IMPORTANT: Always use search URLs (not direct video links) to ensure videos are always available.
   Format search query as: exercise+name+how+to+do+proper+form (replace spaces with +)
   Example: For "Push Ups" use: https://www.youtube.com/results?search_query=push+ups+how+to+do+proper+form]

Repeat for all ${userData.trainingDays} days.

IMPORTANT FOR VIDEO URLS:
- For EACH exercise, you MUST include a "Video URL:" line with a YouTube SEARCH URL (not direct video link)
- ALWAYS use search URLs format: https://www.youtube.com/results?search_query=exercise+name+how+to+do+proper+form
- Replace spaces with + in search queries
- Use the exercise name in the search query
- Add "+how+to+do+proper+form" to the end of the search query for better results
- Make sure the video URL is on a separate line right after each exercise
- Search URLs are more reliable than direct video links as they always show available videos

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
10. VIDEO URLS REQUIRED: Every single exercise MUST have a Video URL line with a YouTube link. This is mandatory.

START YOUR RESPONSE WITH "===DIET PLAN===":
''';
}

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

  int _calculateBaseCalories(OnboardingData userData) {
    final age = userData.age ?? 30;
    final weight = userData.weight ?? 70;
    final height = userData.height ?? 170;
    final isMale = userData.gender?.toLowerCase() == 'male';
    
    double bmr = (10 * weight) + (6.25 * height) - (5 * age) + (isMale ? 5 : -161);
    
    double activityMultiplier = 1.2; 
    if (userData.trainingDays != null) {
      if (userData.trainingDays! >= 5) {
        activityMultiplier = 1.725; 
      } else if (userData.trainingDays! >= 3) {
        activityMultiplier = 1.55; 
      } else if (userData.trainingDays! >= 1) {
        activityMultiplier = 1.375; 
      }
    }
    
    double goalAdjustment = 1.0;
    final goal = userData.workoutGoal?.toLowerCase() ?? '';
    if (goal.contains('lose')) {
      goalAdjustment = 0.85; 
    } else if (goal.contains('build') || goal.contains('gain')) {
      goalAdjustment = 1.15; 
    }
    
    final dailyCalories = (bmr * activityMultiplier * goalAdjustment).round();
    
    return dailyCalories.clamp(1200, 4000);
  }
  
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
        'temperature': 0.5,  //control creativity of responses more lower more precise
        'max_tokens': 8000,
        'stream': false, //getting full response at once
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

 
  Map<String, String> _parsePlans(String response) {
  print('🔍 Parsing AI response...');
  print('📄 Response length: ${response.length} characters');
  
  final dietMarker = RegExp(r'===\s*DIET\s*PLAN\s*===', caseSensitive: false);
  final workoutMarker = RegExp(r'===\s*WORKOUT\s*PLAN\s*===', caseSensitive: false);
  
  final dietMarkerMatch = dietMarker.firstMatch(response);
  final workoutMarkerMatch = workoutMarker.firstMatch(response);
  
  if (dietMarkerMatch != null && workoutMarkerMatch != null) {
    print('✅ Found both markers!');
    
    final dietStart = dietMarkerMatch.end;
    final workoutStart = workoutMarkerMatch.start;
    final dietContent = response.substring(dietStart, workoutStart).trim();
    
    
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
  
  
  return {
    'diet': response,
    'workout': 'Could not separate workout plan - markers not found in response',
  };
}
}