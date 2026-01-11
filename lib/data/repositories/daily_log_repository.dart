import 'package:ai_personal_trainer/models/MonthlyStats.dart';
import '../../models/daily_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyLogRepository {
  final supabase = Supabase.instance.client;

  Future<List<DailyLog>> getAllLogs(String userId) async {
    final response = await supabase
        .from('daily_logs')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);
    
    if (response.isEmpty) return [];
    
    return (response as List)
        .map((e) => DailyLog.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<String?> getPeriodStart(String userId) async {
    final response = await supabase
        .from('daily_logs')
        .select('date')
        .eq('user_id', userId)
        .order('date', ascending: true)
        .limit(1);
    
    if (response.isEmpty) return null;
    return (response as List).first['date'] as String?;
  }

  Future<int> countDietDays(String userId, String start, String end) async {
    final response = await supabase
        .from('daily_logs')
        .select('date')
        .eq('user_id', userId)
        .eq('diet_done', 1)
        .gte('date', start)
        .lte('date', end);
    
    return (response as List).length;
  }

  Future<int> countWorkoutDays(String userId, String start, String end) async {
    final response = await supabase
        .from('daily_logs')
        .select('date')
        .eq('user_id', userId)
        .eq('workout_done', 1)
        .gte('date', start)
        .lte('date', end);
    
    return (response as List).length;
  }

  Future<List<MonthlyStats>> getMonthlyStats(String userId) async {
    final response = await supabase
        .from('daily_logs')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: true);

    if (response.isEmpty) return [];

    final logs = (response as List)
        .map((e) => DailyLog.fromMap(e as Map<String, dynamic>))
        .toList();

    // Group by month
    final Map<String, List<DailyLog>> logsByMonth = {};
    for (var log in logs) {
      final month = log.date.substring(0, 7); // "YYYY-MM"
      logsByMonth.putIfAbsent(month, () => []).add(log);
    }

    // Compute stats
    final List<MonthlyStats> statsList = [];
    logsByMonth.forEach((month, logs) {
      final dietDays = logs.where((l) => l.dietDone).length;
      final workoutDays = logs.where((l) => l.workoutDone).length;
      final totalDays = logs.length;

      statsList.add(MonthlyStats(
        month: month,
        dietDays: dietDays,
        workoutDays: workoutDays,
        totalDays: totalDays,
      ));
    });

    // Sort months descending
    statsList.sort((a, b) => b.month.compareTo(a.month));
    return statsList;
  }
}