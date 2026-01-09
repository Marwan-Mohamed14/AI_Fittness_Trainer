import 'package:ai_personal_trainer/models/MonthlyStats.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../db_helper.dart';
import '../../models/daily_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyLogRepository {
  final supabase = Supabase.instance.client;

  Future<void> logToday({
    required String userId,
    bool? dietDone,
    bool? workoutDone,
  }) async {
    final db = await DBHelper.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

 
    final existing = await db.query(
      'daily_logs',
      where: 'date = ? AND user_id = ?',
      whereArgs: [today, userId],
    );

    if (existing.isNotEmpty) {
   
      final existingLog = DailyLog.fromMap(existing.first);
      await db.update(
        'daily_logs',
        {
          'diet_done': dietDone ?? existingLog.dietDone ? 1 : 0,
          'workout_done': workoutDone ?? existingLog.workoutDone ? 1 : 0,
          'created_at': DateTime.now().toIso8601String(),
        },
        where: 'date = ? AND user_id = ?',
        whereArgs: [today, userId],
      );
    } else {
   
      await db.insert(
        'daily_logs',
        {
          'date': today,
          'user_id': userId,
          'diet_done': (dietDone ?? false) ? 1 : 0,
          'workout_done': (workoutDone ?? false) ? 1 : 0,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<DailyLog>> getAllLogs(String userId) async {
    final db = await DBHelper.database;
    final result = await db.query(
      'daily_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return result.map((e) => DailyLog.fromMap(e)).toList();
  }

  Future<String?> getPeriodStart(String userId) async {
    final db = await DBHelper.database;
    final res = await db.rawQuery(
      'SELECT MIN(date) as start FROM daily_logs WHERE user_id = ?',
      [userId],
    );
    return res.first['start'] as String?;
  }

  Future<int> countDietDays(String userId, String start, String end) async {
    final db = await DBHelper.database;
    final res = await db.rawQuery('''
      SELECT COUNT(*) as c FROM daily_logs
      WHERE user_id = ? AND diet_done = 1 AND date BETWEEN ? AND ?
    ''', [userId, start, end]);
    return res.first['c'] as int;
  }

  Future<int> countWorkoutDays(String userId, String start, String end) async {
    final db = await DBHelper.database;
    final res = await db.rawQuery('''
      SELECT COUNT(*) as c FROM daily_logs
      WHERE user_id = ? AND workout_done = 1 AND date BETWEEN ? AND ?
    ''', [userId, start, end]);
    return res.first['c'] as int;
  }

  Future<DailyLog?> getTodayLog(String userId) async {
    final db = await DBHelper.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final result = await db.query(
      'daily_logs',
      where: 'date = ? AND user_id = ?',
      whereArgs: [today, userId],
    );
    if (result.isEmpty) return null;
    return DailyLog.fromMap(result.first);
  }
 Future<List<MonthlyStats>> getMonthlyStats(String userId) async {
    final response = await supabase
        .from('daily_logs')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: true);

    if (response == null || response.isEmpty) return [];

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