class OnboardingData {

  int? age;
  int? height;
  String? gender;


  String? workoutGoal;       
  String? workoutLevel;      
  int? trainingDays;       
  String? trainingLocation; 


  String? dietPreference;   
  int? mealsPerDay;
  String? budget;             


  int? weight;             
  int? targetWeight;        


  String? activityLevel;    

  List<String>? allergies;    

  String? dietPlan;
  String? workoutPlan;

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
    this.dietPlan,
    this.workoutPlan,
  });



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
      "diet_plan": dietPlan,
      "workout_plan": workoutPlan,

    };
  }

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
   dietPlan: json['diet_plan'],
   workoutPlan: json['workout_plan'],
  );
}
}
