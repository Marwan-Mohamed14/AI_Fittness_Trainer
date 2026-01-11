import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../models/daily_log.dart';
import '../services/Authservice.dart';
import 'package:ai_personal_trainer/supabase_config.dart';

class DailyCheckupController extends GetxController {
  final repo = DailyLogRepository();
  final authService = AuthService();
  final RxMap<String, bool> mealCompletion = <String, bool>{}.obs;
  final RxMap<int, bool> workoutCompletion = <int, bool>{}.obs;
  final todayLogged = false.obs;
  final todayDietDone = false.obs;
  final todayWorkoutDone = false.obs;
  final streak = 0.obs;
  final dietCount = 0.obs;
  final workoutCount = 0.obs;
  String? get userId => authService.getCurrentUserId();

  bool get dietDone =>
      mealCompletion.isNotEmpty && mealCompletion.values.every((v) => v);

  bool get workoutDone =>
      workoutCompletion.isNotEmpty && workoutCompletion.values.any((v) => v);

  bool get canLog => dietDone || workoutDone;

  String get formattedDate =>
      DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
  @override
  void onInit() {
    super.onInit();
    _loadToday().then((_) => refreshStats());
  }
  void initMeals(List<String> meals) {
    for (final meal in meals) {
      mealCompletion.putIfAbsent(meal, () => false);
    }
  }

  void initWorkout(int count) {
    for (int i = 0; i < count; i++) {
      workoutCompletion.putIfAbsent(i, () => false);
    }
  }
  void updateMeal(String key, bool value) {
    mealCompletion[key] = value;
    // Don't save here - only save when button is clicked
  }

  void updateWorkout(int index, bool value) {
    workoutCompletion[index] = value;
    // Don't save here - only save when button is clicked
  }
  Future<void> _loadToday() async {
    final uid = userId;
    if (uid == null) return;

    // Reset state for new day
    final todayStr = _today();
    final res = await SupabaseConfig.client
        .from('daily_logs')
        .select()
        .eq('user_id', uid)
        .eq('date', todayStr)
        .maybeSingle();

    // Reset state
    todayLogged.value = false;
    todayDietDone.value = false;
    todayWorkoutDone.value = false;
    mealCompletion.clear();
    workoutCompletion.clear();

    if (res != null) {
      // Only mark as logged if there's actual data for today
      todayLogged.value = true;
      todayDietDone.value = res['diet_done'] == 1;
      todayWorkoutDone.value = res['workout_done'] == 1;

      final mealState = res['meal_state'];
      if (mealState is Map) {
        mealCompletion.assignAll(
          mealState.map((k, v) => MapEntry(k.toString(), v == true)),
        );
      }

      final workoutState = res['workout_state'];
      if (workoutState is Map) {
        workoutCompletion.assignAll(
          workoutState.map(
            (k, v) => MapEntry(int.parse(k.toString()), v == true),
          ),
        );
      }
    }
  }

  Future<void> saveToday() async {
    final uid = userId;
    if (uid == null || !canLog) return;

    await SupabaseConfig.client.from('daily_logs').upsert(
      {
        'user_id': uid,
        'date': _today(),
        'diet_done': dietDone ? 1 : 0,
        'workout_done': workoutDone ? 1 : 0,
        'meal_state': Map<String, bool>.from(mealCompletion),
        'workout_state': workoutCompletion.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
      },
      onConflict: 'user_id,date',
    );

    todayLogged.value = true;
    todayDietDone.value = dietDone;
    todayWorkoutDone.value = workoutDone;
    
    // Refresh stats after saving
    await refreshStats();
  }

  Future<void> refreshStats() async {
    final uid = userId;
    if (uid == null) return;

    final logs = await repo.getAllLogs(uid);
    streak.value = _calculateStreak(logs);

    final period = await _getCurrentPeriod(uid);
    if (period == null) return;

    dietCount.value =
        await repo.countDietDays(uid, period.start, period.end);
    workoutCount.value =
        await repo.countWorkoutDays(uid, period.start, period.end);
  }

  int _calculateStreak(List<DailyLog> logs) {
    if (logs.isEmpty) return 0;
    
    // Sort logs by date descending (most recent first)
    logs.sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    
    int logIndex = 0;
    
    // Check if today is logged
    if (logIndex < logs.length) {
      final firstLog = logs[logIndex];
      final firstLogDate = DateTime.parse(firstLog.date);
      final firstLogDateOnly = DateTime(firstLogDate.year, firstLogDate.month, firstLogDate.day);
      
      if (_isSameDay(firstLogDateOnly, currentDate)) {
        // Today is logged, check if it's done
        if (firstLog.dietDone || firstLog.workoutDone) {
          streak++;
          logIndex++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          // Today is logged but not done, streak is 0
          return 0;
        }
      } else {
        // Today is not logged, streak starts from yesterday
        currentDate = currentDate.subtract(const Duration(days: 1));
      }
    }
    
    // Count consecutive days going backwards
    while (logIndex < logs.length) {
      final log = logs[logIndex];
      final logDate = DateTime.parse(log.date);
      final logDateOnly = DateTime(logDate.year, logDate.month, logDate.day);
      
      if (_isSameDay(logDateOnly, currentDate)) {
        if (log.dietDone || log.workoutDone) {
          streak++;
          logIndex++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          // Found a day that's logged but not done, break streak
          break;
        }
      } else if (logDateOnly.isBefore(currentDate)) {
        // There's a gap, break streak
        break;
      } else {
        // Skip this log (shouldn't happen with sorted list)
        logIndex++;
      }
    }
    
    return streak;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _today() =>
      DateTime.now().toIso8601String().split('T')[0];

  Future<_Period?> _getCurrentPeriod(String userId) async {
    // Always use a rolling 30-day window from today
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final periodStart = todayOnly.subtract(const Duration(days: 29));
    final periodEnd = todayOnly;
    
    return _Period(
      start: DateFormat('yyyy-MM-dd').format(periodStart),
      end: DateFormat('yyyy-MM-dd').format(periodEnd),
    );
  }
}

class _Period {
  final String start;
  final String end;

  _Period({required this.start, required this.end});
}
