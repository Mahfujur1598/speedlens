import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    final dbPath = join(await getDatabasesPath(), 'speedtest.db');

    _db = await openDatabase(
      dbPath,
      version: 2, // ✅ bump version (schema fixed)
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE speed_tests(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ts INTEGER NOT NULL,
            download_mbps REAL NOT NULL,
            upload_mbps REAL NOT NULL,
            ping_ms REAL NOT NULL,
            jitter_ms REAL,
            server TEXT,
            ip TEXT
          );
        ''');
      },
      onUpgrade: (d, oldV, newV) async {
        // ✅ simplest upgrade path (practice-friendly):
        // If old schema exists, recreate.
        if (oldV < 2) {
          await d.execute('DROP TABLE IF EXISTS speed_tests;');
          await d.execute('''
            CREATE TABLE speed_tests(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              ts INTEGER NOT NULL,
              download_mbps REAL NOT NULL,
              upload_mbps REAL NOT NULL,
              ping_ms REAL NOT NULL,
              jitter_ms REAL,
              server TEXT,
              ip TEXT
            );
          ''');
        }
      },
    );

    return _db!;
  }
}