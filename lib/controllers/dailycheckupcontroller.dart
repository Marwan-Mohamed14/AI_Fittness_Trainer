import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../models/daily_log.dart';
import '../services/Authservice.dart';

class DailyCheckupController extends GetxController {
  final repo = DailyLogRepository();
  final authService = AuthService();

  // UI state
  var mealCompletion = <String, bool>{}.obs;
  var workoutCompletion = <int, bool>{}.obs;

  // Dashboard state
  var streak = 0.obs;
  var dietCount = 0.obs;
  var workoutCount = 0.obs;
  var todayLogged = false.obs;
  var todayDietDone = false.obs;
  var todayWorkoutDone = false.obs;

  bool get dietDone =>
      mealCompletion.isNotEmpty && mealCompletion.values.every((v) => v);

  bool get workoutDone =>
      workoutCompletion.isNotEmpty && workoutCompletion.values.every((v) => v);

  bool get canLog => dietDone || workoutDone;

  String? get userId => authService.getCurrentUserId();

  @override
  void onInit() {
    super.onInit();
    refreshStats();
    checkTodayLog();
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

  // Check if today is already logged
  Future<void> checkTodayLog() async {
    final uid = userId;
    if (uid == null) {
      todayLogged.value = false;
      todayDietDone.value = false;
      todayWorkoutDone.value = false;
      return;
    }

    final todayLog = await repo.getTodayLog(uid);
    if (todayLog != null) {
      todayLogged.value = true;
      todayDietDone.value = todayLog.dietDone;
      todayWorkoutDone.value = todayLog.workoutDone;
    } else {
      todayLogged.value = false;
      todayDietDone.value = false;
      todayWorkoutDone.value = false;
    }
  }

  // Log diet only, workout only, or both
  Future<void> logDayIfCompleted() async {
    final uid = userId;
    if (uid == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }

    if (!canLog) return;

    // Log based on what's completed
    await repo.logToday(
      userId: uid,
      dietDone: dietDone,
      workoutDone: workoutDone,
    );

    mealCompletion.clear();
    workoutCompletion.clear();

    await checkTodayLog();
    await refreshStats();
  }

  // =====================
  // STREAK + 30 DAY LOGIC
  // =====================
  Future<void> refreshStats() async {
    final uid = userId;
    if (uid == null) {
      streak.value = 0;
      dietCount.value = 0;
      workoutCount.value = 0;
      return;
    }

    final logs = await repo.getAllLogs(uid);
    streak.value = _calculateStreak(logs);

    final period = await _getCurrentPeriod(uid);
    if (period == null) {
      dietCount.value = 0;
      workoutCount.value = 0;
      return;
    }

    dietCount.value = await repo.countDietDays(uid, period.start, period.end);
    workoutCount.value = await repo.countWorkoutDays(uid, period.start, period.end);
  }

  int _calculateStreak(List<DailyLog> logs) {
    int s = 0;
    DateTime current = DateTime.now();

    for (final log in logs) {
      final logDate = DateTime.parse(log.date);
      // Streak continues if at least one is done (diet OR workout)
      if ((log.dietDone || log.workoutDone) && _isSameDay(logDate, current)) {
        s++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return s;
  }

  Future<_Period?> _getCurrentPeriod(String userId) async {
    final startStr = await repo.getPeriodStart(userId);
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
