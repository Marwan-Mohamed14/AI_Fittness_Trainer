import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../models/daily_log.dart';

class DailyCheckupController extends GetxController {
  final repo = DailyLogRepository();

  // UI state
  var mealCompletion = <String, bool>{}.obs;
  var workoutCompletion = <int, bool>{}.obs;

  // Dashboard state
  var streak = 0.obs;
  var dietCount = 0.obs;
  var workoutCount = 0.obs;

  bool get dietDone =>
      mealCompletion.isNotEmpty && mealCompletion.values.every((v) => v);

  bool get workoutDone =>
      workoutCompletion.isNotEmpty && workoutCompletion.values.every((v) => v);

  bool get allDone => dietDone && workoutDone;

  @override
  void onInit() {
    super.onInit();
    refreshStats();
  }

  void initMeals(List<String> meals) {
    if (mealCompletion.isEmpty) {
      for (var m in meals) mealCompletion[m] = false;
    }
  }

  void initWorkout(int count) {
    if (workoutCompletion.isEmpty) {
      for (var i = 0; i < count; i++) workoutCompletion[i] = false;
    }
  }

  void updateMeal(String key, bool value) {
    mealCompletion[key] = value;
  }

  void updateWorkout(int index, bool value) {
    workoutCompletion[index] = value;
  }

  // 🔐 ONE LOG PER DAY
  Future<void> logDayIfCompleted() async {
    if (!allDone) return;

    await repo.logToday();

    mealCompletion.clear();
    workoutCompletion.clear();

    await refreshStats();
  }

  // =====================
  // STREAK + 30 DAY LOGIC
  // =====================
  Future<void> refreshStats() async {
    final logs = await repo.getAllLogs();
    streak.value = _calculateStreak(logs);

    final period = await _getCurrentPeriod();
    if (period == null) {
      dietCount.value = 0;
      workoutCount.value = 0;
      return;
    }

    dietCount.value =
        await repo.countDietDays(period.start, period.end);
    workoutCount.value =
        await repo.countWorkoutDays(period.start, period.end);
  }

  int _calculateStreak(List<DailyLog> logs) {
    int s = 0;
    DateTime current = DateTime.now();

    for (final log in logs) {
      final logDate = DateTime.parse(log.date);
      if (log.dietDone && log.workoutDone && _isSameDay(logDate, current)) {
        s++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return s;
  }

  Future<_Period?> _getCurrentPeriod() async {
    final startStr = await repo.getPeriodStart();
    if (startStr == null) return null;

    final start = DateTime.parse(startStr);
    final end = start.add(const Duration(days: 29));

    // 🔁 RESET AFTER 30 DAYS (DONE OR NOT)
    if (DateTime.now().isAfter(end)) return null;

    return _Period(
      start: DateFormat('yyyy-MM-dd').format(start),
      end: DateFormat('yyyy-MM-dd').format(end),
    );
  }

  String get formattedDate =>
      DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Period {
  final String start;
  final String end;
  _Period({required this.start, required this.end});
}
