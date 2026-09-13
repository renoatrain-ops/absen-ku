import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('absensi.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(docsDir.path, fileName);

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pihak (
        id_pihak INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_lengkap TEXT,
        nama_alias TEXT,
        kode_pihak TEXT UNIQUE,
        flag_aktif INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE absensi (
        id_absensi INTEGER PRIMARY KEY AUTOINCREMENT,
        tgl_hadir TEXT,
        kode_pihak TEXT
      )
    ''');
  }

  Future<int> insertPihakIfNotExists(String kodePihak) async {
    final db = await instance.database;
    final existing = await db.query(
      'pihak',
      where: 'kode_pihak = ?',
      whereArgs: [kodePihak],
      limit: 1,
    );
    if (existing.isNotEmpty) return existing.first['id_pihak'] as int;

    return await db.insert('pihak', {
      'nama_lengkap': '',
      'nama_alias': '',
      'kode_pihak': kodePihak,
      'flag_aktif': 0,
    });
  }

  Future<Map<String, dynamic>?> getPihakByKode(String kodePihak) async {
    final db = await instance.database;
    final res = await db.query(
      'pihak',
      where: 'kode_pihak = ?',
      whereArgs: [kodePihak],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return res.first;
  }

  Future<int> insertAbsensi(String kodePihak) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('absensi', {
      'tgl_hadir': now,
      'kode_pihak': kodePihak,
    });
  }

  Future<List<Map<String, dynamic>>> getAllAbsensi() async {
    final db = await instance.database;
    return await db.query('absensi', orderBy: 'tgl_hadir DESC');
  }

  Future<List<Map<String, dynamic>>> getAbsensiByDate(DateTime date) async {
    final db = await instance.database;
    final dateStr = date.toIso8601String().substring(0, 10); // yyyy-MM-dd
    return await db.query('absensi', where: "tgl_hadir LIKE ?", whereArgs: ['$dateStr%'], orderBy: 'tgl_hadir DESC');
  }

  Future<List<Map<String, dynamic>>> getAllPihak() async {
    final db = await instance.database;
    return await db.query('pihak', orderBy: 'nama_alias');
  }

  Future<int> insertPihak(Map<String, dynamic> pihak) async {
    final db = await instance.database;
    return await db.insert('pihak', pihak);
  }

  Future<int> updatePihak(int idPihak, Map<String, dynamic> pihak) async {
    final db = await instance.database;
    return await db.update('pihak', pihak, where: 'id_pihak = ?', whereArgs: [idPihak]);
  }

  Future<int> deletePihak(int idPihak) async {
    final db = await instance.database;
    return await db.delete('pihak', where: 'id_pihak = ?', whereArgs: [idPihak]);
  }

  Future<int> deleteAbsensi(int idAbsensi) async {
    final db = await instance.database;
    return await db.delete('absensi', where: 'id_absensi = ?', whereArgs: [idAbsensi]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
