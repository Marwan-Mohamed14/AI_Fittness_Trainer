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
      "allergies": allergies,
    };
  }
  // Add this to your OnboardingData class
factory OnboardingData.fromJson(Map<String, dynamic> json) {
  return OnboardingData(
    age: json['age'],
    height: json['height'],
    gender: json['gender'],
    workoutGoal: json['workout_goal'],
    workoutLevel: json['workout_level'],
    trainingDays: json['training_days'],
    trainingLocation: json['training_location'],
    dietPreference: json['diet_preference'],
    mealsPerDay: json['meals_per_day'],
    budget: json['budget'],
    weight: json['weight'],
    targetWeight: json['target_weight'],
    allergies: json['allergies'] != null 
        ? List<String>.from(json['allergies']) 
        : null,
   
  );
}
}
