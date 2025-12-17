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
  return '''
Create a ${userData.trainingDays}-day fitness plan. Use this EXACT format:

===DIET PLAN===
BREAKFAST (Daily): [eggs dish] - XXX kcal | P: XXg C: XXg F: XXg
LUNCH (Daily): [meal] - XXX kcal | P: XXg C: XXg F: XXg
DINNER (Daily): [chicken dish] - XXX kcal | P: XXg C: XXg F: XXg
DAILY TOTAL: XXXX kcal | P: XXXg C: XXXg F: XXXg

===WORKOUT PLAN===
DAY 1: PUSH
1. Exercise - Sets x Reps
2. Exercise - Sets x Reps
[continue for all exercises]

DAY 2: PULL
1. Exercise - Sets x Reps
[continue...]

[Continue for all ${userData.trainingDays} days]

USER:
Age: ${userData.age}, ${userData.gender}
Weight: ${userData.weight}kg → ${userData.targetWeight}kg
Goal: ${userData.workoutGoal}
Level: ${userData.workoutLevel}
Training: ${userData.trainingDays} days/week at ${userData.trainingLocation}
Diet: ${userData.dietPreference}, Allergies: ${userData.allergies?.join(', ') ?? 'None'}

IMPORTANT:
- Be CONCISE - no explanations, just the plan
- Include ALL ${userData.trainingDays} workout days
- Breakfast: eggs, Dinner: chicken (always)
- ${userData.trainingLocation == 'Gym' ? 'Use gym equipment' : 'Use bodyweight/dumbbells'}

START WITH "===DIET PLAN===":
''';
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
  
  // Print full response for debugging
  print('=' * 80);
  print('📄 FULL AI RESPONSE:');
  print(response);
  print('=' * 80);
  
  // More flexible regex
  final dietPattern = RegExp(
    r'===\s*DIET\s*PLAN\s*===\s*(.*?)(?:===\s*WORKOUT\s*PLAN\s*===|$)',
    dotAll: true,
    caseSensitive: false,
  );
  
  final workoutPattern = RegExp(
    r'===\s*WORKOUT\s*PLAN\s*===\s*(.*?)$',
    dotAll: true,
    caseSensitive: false,
  );
  
  final dietMatch = dietPattern.firstMatch(response);
  final workoutMatch = workoutPattern.firstMatch(response);
  
  if (dietMatch != null && workoutMatch != null) {
    print('✅ Found both markers!');
    return {
      'diet': dietMatch.group(1)?.trim() ?? 'Empty diet plan',
      'workout': workoutMatch.group(1)?.trim() ?? 'Empty workout plan',
    };
  }
  
  print('⚠️ Markers not found, returning full response');
  return {
    'diet': response,
    'workout': 'Could not separate workout plan - see full response above',
  };
}
}