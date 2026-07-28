import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../utils/app_logger.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'resepsi_tamu.db');

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tamu(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        instansi TEXT,
        keperluan TEXT,
        tanggal_waktu TEXT,
        path_tanda_tangan TEXT,
        pesan TEXT,
        path_foto TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE tamu ADD COLUMN pesan TEXT DEFAULT ''");
      await db.execute("ALTER TABLE tamu ADD COLUMN path_foto TEXT DEFAULT ''");
    }
  }

  Future<int> insertTamu(Map<String, dynamic> row) async {
    AppLogger.database('INSERT', table: 'tamu', detail: 'nama=${row['nama']}');
    Database db = await database;
    final id = await db.insert('tamu', row);
    AppLogger.database('INSERT OK', table: 'tamu', detail: 'id=$id');
    return id;
  }

  Future<List<Map<String, dynamic>>> getAllTamu() async {
    AppLogger.database('SELECT', table: 'tamu', detail: 'getAllTamu');
    Database db = await database;
    final results = await db.query('tamu', orderBy: 'tanggal_waktu DESC');
    AppLogger.database('SELECT OK', table: 'tamu', detail: '${results.length} rows');
    return results;
  }

  Future<List<Map<String, dynamic>>> searchTamu(String keyword) async {
    AppLogger.database('SEARCH', table: 'tamu', detail: 'keyword="$keyword"');
    Database db = await database;
    final results = await db.query(
      'tamu',
      where: 'nama LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'tanggal_waktu DESC',
    );
    AppLogger.database('SEARCH OK', table: 'tamu', detail: '${results.length} rows');
    return results;
  }

  /// Hitung total seluruh tamu
  Future<int> getTotalTamu() async {
    Database db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM tamu');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Hitung tamu hari ini (berdasarkan tanggal lokal)
  Future<int> getTodayTamu() async {
    Database db = await database;
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM tamu WHERE tanggal_waktu >= ? AND tanggal_waktu < ?',
      [todayStart.toIso8601String(), todayEnd.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
