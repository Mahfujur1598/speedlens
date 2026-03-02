import '../../model/speed_test_record.dart';
import '../db/app_db.dart';
import 'package:sqflite/sqflite.dart';

class SpeedTestRepo {
  Future<int> insert(SpeedTestRecord r) async {
    final d = await AppDb.db;
    return d.insert(
      'speed_tests',
      r.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // replace -> id থাকলে replace, না থাকলে insert
  }

  Future<List<SpeedTestRecord>> getAll() async {
    final d = await AppDb.db;
    final rows = await d.query('speed_tests', orderBy: 'ts DESC');
    return rows.map(SpeedTestRecord.fromMap).toList();
  }

  Future<void> deleteOne(int id) async {
    final d = await AppDb.db;
    await d.delete('speed_tests', where: 'id=?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final d = await AppDb.db;
    await d.delete('speed_tests');
  }
}