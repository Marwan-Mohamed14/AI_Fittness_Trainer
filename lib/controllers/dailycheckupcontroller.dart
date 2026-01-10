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
  }

  void updateWorkout(int index, bool value) {
    workoutCompletion[index] = value;
  }
  Future<void> _loadToday() async {
    final uid = userId;
    if (uid == null) return;

    final res = await SupabaseConfig.client
        .from('daily_logs')
        .select()
        .eq('user_id', uid)
        .eq('date', _today())
        .maybeSingle();

    if (res == null) return;

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
    int s = 0;
    DateTime current = DateTime.now();

    for (final log in logs) {
      final d = DateTime.parse(log.date);
      if ((log.dietDone || log.workoutDone) && _isSameDay(d, current)) {
        s++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return s;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _today() =>
      DateTime.now().toIso8601String().split('T')[0];

  Future<_Period?> _getCurrentPeriod(String userId) async {
    final startStr = await repo.getPeriodStart(userId);
    if (startStr == null) return null;

    final start = DateTime.parse(startStr);
    final end = start.add(const Duration(days: 29));

    if (DateTime.now().isAfter(end)) return null;

    return _Period(
      start: DateFormat('yyyy-MM-dd').format(start),
      end: DateFormat('yyyy-MM-dd').format(end),
    );
  }
}

class _Period {
  final String start;
  final String end;

  _Period({required this.start, required this.end});
}
