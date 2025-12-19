import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DailyCheckupController extends GetxController {
  var completedDiet = false.obs;
  var completedWorkout = false.obs;
  var currentDate = DateTime.now().obs;

  // Track meals & workouts for today's checkup
  var mealCompletion = <String, bool>{}.obs; // e.g., {"breakfast": false, "lunch": false, "dinner": false}
  var workoutCompletion = <int, bool>{}.obs; // e.g., exercise index -> completed

  // Updated getters to avoid empty map issue
  bool get dietDone => mealCompletion.isNotEmpty && mealCompletion.values.every((v) => v);
  bool get workoutDone => workoutCompletion.isNotEmpty && workoutCompletion.values.every((v) => v);
  bool get allDone => dietDone && workoutDone;

  // Initialize meals only once
  void initMeals(List<String> meals) {
    if (mealCompletion.isEmpty) {
      for (var m in meals) mealCompletion[m] = false;
    }
  }

  // Initialize workouts only once
  void initWorkout(int exercisesCount) {
    if (workoutCompletion.isEmpty) {
      for (var i = 0; i < exercisesCount; i++) workoutCompletion[i] = false;
    }
  }

  void updateMeal(String mealKey, bool value) {
    mealCompletion[mealKey] = value;
    completedDiet.value = dietDone;
  }

  void updateWorkout(int index, bool value) {
    workoutCompletion[index] = value;
    completedWorkout.value = workoutDone;
  }

  // Log the day only if it's current day
  void logDayIfCompleted() {
    if (!allDone) return;

    final today = DateTime.now();
    if (!isSameDate(currentDate.value, today)) return;

    currentDate.value = currentDate.value.add(const Duration(days: 1));
    mealCompletion.clear();
    workoutCompletion.clear();
    completedDiet.value = false;
    completedWorkout.value = false;
  }

  String get formattedDate => DateFormat('EEEE, MMM d, yyyy').format(currentDate.value);

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
