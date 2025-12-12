class OnboardingData {
  // Basic Info
  int? age;
  int? height;
  String? gender;

  // Workout
  String? workoutGoal;        // lose weight, build muscle, etc
  String? workoutLevel;       // beginner / intermediate / advanced
  int? trainingDays;          // how many days per week
  String? trainingLocation;   // home or gym

  // Diet
  String? dietPreference;     // low-carb, normal, etc
  int? mealsPerDay;
  String? budget;             // low / medium / high

  // Weight info
  int? weight;                // current weight
  int? targetWeight;          // target weight

  // Lifestyle
  String? activityLevel;      // low / medium / high

  // Restrictions
  List<String>? allergies;    // things they cannot eat
  List<String>? dislikes;     // things they don’t like

  OnboardingData({
    this.age,
    this.height,
    this.gender,
    this.workoutGoal,
    this.workoutLevel,
    this.trainingDays,
    this.trainingLocation,
    this.dietPreference,
    this.mealsPerDay,
    this.budget,
    this.weight,
    this.targetWeight,
    this.activityLevel,
    this.allergies,
    this.dislikes,
  });

  // ================================
  // Convert from Supabase JSON
  // ================================
  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      age: json['age'] as int?,
      height: json['height'] as int?,
      gender: json['gender'] as String?,
      workoutGoal: json['workout_goal'] as String?,
      workoutLevel: json['workout_level'] as String?,
      trainingDays: json['training_days'] as int?,
      trainingLocation: json['training_location'] as String?,
      dietPreference: json['diet_preference'] as String?,
      mealsPerDay: json['meals_per_day'] as int?,
      budget: json['budget'] as String?,
      weight: json['weight'] as int?,
      targetWeight: json['target_weight'] as int?,
      activityLevel: json['activity_level'] as String?,
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies'] as List) 
          : null,
      dislikes: json['dislikes'] != null 
          ? List<String>.from(json['dislikes'] as List) 
          : null,
    );
  }

  // ================================
  // Convert to Map for Supabase JSON
  // ================================
  Map<String, dynamic> toJson() {
    return {
      "age": age,
      "height": height,
      "gender": gender,
      "workout_goal": workoutGoal,
      "workout_level": workoutLevel,
      "training_days": trainingDays,
      "training_location": trainingLocation,
      "diet_preference": dietPreference,
      "meals_per_day": mealsPerDay,
      "budget": budget,
      "weight": weight,
      "target_weight": targetWeight,
      "activity_level": activityLevel,
      "allergies": allergies,
      "dislikes": dislikes,
    };
  }
}
