import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../db_helper.dart';
import '../../models/daily_log.dart';

class DailyLogRepository {
  Future<void> logToday() async {
    final db = await DBHelper.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await db.insert(
      'daily_logs',
      {
        'date': today,
        'diet_done': 1,
        'workout_done': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore, // 👈 prevents double log
    );
  }

  Future<List<DailyLog>> getAllLogs() async {
    final db = await DBHelper.database;
    final result = await db.query('daily_logs', orderBy: 'date DESC');
    return result.map((e) => DailyLog.fromMap(e)).toList();
  }

  Future<String?> getPeriodStart() async {
    final db = await DBHelper.database;
    final res = await db.rawQuery('SELECT MIN(date) as start FROM daily_logs');
    return res.first['start'] as String?;
  }

  Future<int> countDietDays(String start, String end) async {
    final db = await DBHelper.database;
    final res = await db.rawQuery('''
      SELECT COUNT(*) as c FROM daily_logs
      WHERE diet_done = 1 AND date BETWEEN ? AND ?
    ''', [start, end]);
    return res.first['c'] as int;
  }

  Future<int> countWorkoutDays(String start, String end) async {
    final db = await DBHelper.database;
    final res = await db.rawQuery('''
      SELECT COUNT(*) as c FROM daily_logs
      WHERE workout_done = 1 AND date BETWEEN ? AND ?
    ''', [start, end]);
    return res.first['c'] as int;
  }
}
