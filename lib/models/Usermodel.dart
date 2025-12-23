class ProfileModel {
  final String userId;
  final double height;
  final double weight;
  final int age;
  final String gender;
  final int trainingDaysPerWeek;
  final String workoutDifficulty;
  final String goal;
  final String dietType;
  final List<String> preferredFoods;
  final List<String> avoidedFoods;
  final int? dailyCaloriesTarget;
  final Map<String, dynamic>? mealPlan;
  final Map<String, dynamic>? workoutPlan;
  final Map<String, dynamic>? dailySchedule;

  ProfileModel({
    required this.userId,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.trainingDaysPerWeek,
    required this.workoutDifficulty,
    required this.goal,
    required this.dietType,
    this.preferredFoods = const [],
    this.avoidedFoods = const [],
    this.dailyCaloriesTarget,
    this.mealPlan,
    this.workoutPlan,
    this.dailySchedule,
  });


  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'],
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      trainingDaysPerWeek: json['training_days_per_week'] ?? 0,
      workoutDifficulty: json['workout_difficulty'] ?? '',
      goal: json['goal'] ?? '',
      dietType: json['diet_type'] ?? '',
      preferredFoods: List<String>.from(json['preferred_foods'] ?? []),
      avoidedFoods: List<String>.from(json['avoided_foods'] ?? []),
      dailyCaloriesTarget: json['daily_calories_target'],
      mealPlan: json['meal_plan'] ?? {},
      workoutPlan: json['workout_plan'] ?? {},
      dailySchedule: json['daily_schedule'] ?? {},
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'training_days_per_week': trainingDaysPerWeek,
      'workout_difficulty': workoutDifficulty,
      'goal': goal,
      'diet_type': dietType,
      'preferred_foods': preferredFoods,
      'avoided_foods': avoidedFoods,
      'daily_calories_target': dailyCaloriesTarget,
      'meal_plan': mealPlan,
      'workout_plan': workoutPlan,
      'daily_schedule': dailySchedule,
    };
  }
}
