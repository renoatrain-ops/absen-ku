import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS pihak');
          await _createPihak(db);
          await db.execute('ALTER TABLE absensi RENAME TO absensi_legacy');
          await db.execute('''
            CREATE TABLE absensi (
              id_absensi INTEGER PRIMARY KEY AUTOINCREMENT,
              tgl_hadir TEXT,
              kode_unik TEXT
            )
          ''');
          await db.execute('''
            INSERT INTO absensi (id_absensi, tgl_hadir, kode_unik)
            SELECT id_absensi, tgl_hadir, kode_pihak FROM absensi_legacy
          ''');
          await db.execute('DROP TABLE absensi_legacy');
          await _seedPihak(db);
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await _createPihak(db);

    await db.execute('''
      CREATE TABLE absensi (
        id_absensi INTEGER PRIMARY KEY AUTOINCREMENT,
        tgl_hadir TEXT,
        kode_unik TEXT
      )
    ''');
    await _seedPihak(db);
  }

  Future<void> _createPihak(Database db) async {
    await db.execute('''
      CREATE TABLE pihak (
        id INTEGER PRIMARY KEY,
        id_pihak TEXT,
        tipe TEXT,
        nama TEXT,
        kode_unik TEXT UNIQUE,
        kode_induk TEXT,
        flag TEXT,
        grade TEXT,
        aktif INTEGER
      )
    ''');
  }

  Future<void> _seedPihak(Database db) async {
    try {
      final response = await http
          .get(Uri.parse(
            'https://raw.githubusercontent.com/renoatrain-ops/absen-ku/main/app/docs/pihak.json',
          ))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return;
      final rows = jsonDecode(response.body) as List<dynamic>;
      final batch = db.batch();
      for (final row in rows) {
        batch.insert('pihak', Map<String, dynamic>.from(row));
      }
      await batch.commit(noResult: true);
    } catch (_) {}
  }

  Future<int> insertPihakIfNotExists(String kodePihak) async {
    final db = await instance.database;
    final existing = await db.query(
      'pihak',
      where: 'kode_unik = ?',
      whereArgs: [kodePihak],
      limit: 1,
    );
    if (existing.isNotEmpty) return existing.first['id'] as int;

    return await db.insert('pihak', {
      'id': DateTime.now().millisecondsSinceEpoch,
      'id_pihak': kodePihak,
      'tipe': 'UNKNOWN',
      'nama': '',
      'kode_unik': kodePihak,
      'kode_induk': '',
      'flag': '',
      'grade': '',
      'aktif': 0,
    });
  }

  Future<Map<String, dynamic>?> getPihakByKode(String kodePihak) async {
    final db = await instance.database;
    final res = await db.query(
      'pihak',
      where: 'kode_unik = ?',
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
      'kode_unik': kodePihak,
    });
  }

  Future<List<Map<String, dynamic>>> getAllAbsensi() async {
    final db = await instance.database;
    return await db.query('absensi', orderBy: 'tgl_hadir DESC');
  }

  Future<List<Map<String, dynamic>>> getAbsensiByDate(DateTime date) async {
    final db = await instance.database;
    final dateStr = date.toIso8601String().substring(0, 10); // yyyy-MM-dd
    return await db.rawQuery('''
      SELECT absensi.*, pihak.nama, pihak.tipe
      FROM absensi
      LEFT JOIN pihak ON pihak.kode_unik = absensi.kode_unik
      WHERE absensi.tgl_hadir LIKE ?
      ORDER BY absensi.tgl_hadir DESC
    ''', ['$dateStr%']);
  }

  Future<List<Map<String, dynamic>>> getAllPihak() async {
    final db = await instance.database;
    return await db.query('pihak', orderBy: 'nama');
  }

  Future<int> insertPihak(Map<String, dynamic> pihak) async {
    final db = await instance.database;
    return await db.insert('pihak', pihak);
  }

  Future<int> updatePihak(int idPihak, Map<String, dynamic> pihak) async {
    final db = await instance.database;
    return await db
        .update('pihak', pihak, where: 'id = ?', whereArgs: [idPihak]);
  }

  Future<int> deletePihak(int idPihak) async {
    final db = await instance.database;
    return await db.delete('pihak', where: 'id = ?', whereArgs: [idPihak]);
  }

  Future<int> deleteAbsensi(int idAbsensi) async {
    final db = await instance.database;
    return await db
        .delete('absensi', where: 'id_absensi = ?', whereArgs: [idAbsensi]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
