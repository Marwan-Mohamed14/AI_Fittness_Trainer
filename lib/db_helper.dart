import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'consistency.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE daily_logs (
            date TEXT,
            user_id TEXT,
            diet_done INTEGER,
            workout_done INTEGER,
            created_at TEXT,
            PRIMARY KEY (date, user_id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
       
          await db.execute('''
            CREATE TABLE daily_logs_new (
              date TEXT,
              user_id TEXT,
              diet_done INTEGER,
              workout_done INTEGER,
              created_at TEXT,
              PRIMARY KEY (date, user_id)
            )
          ''');
          
        
          await db.execute('''
            INSERT INTO daily_logs_new (date, user_id, diet_done, workout_done, created_at)
            SELECT date, 'migrated_user', diet_done, workout_done, created_at
            FROM daily_logs
          ''');
          
          await db.execute('DROP TABLE daily_logs');
          await db.execute('ALTER TABLE daily_logs_new RENAME TO daily_logs');
        }
      },
    );
  }
}
