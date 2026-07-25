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
    // Inisialisasi ffi untuk platform desktop (Windows/Linux)
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Tentukan path database
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'resepsi_tamu.db');

    // Buka (atau buat) database
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
    // Buat tabel tamu
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

  // Migrasi database dari versi 1 ke 2 (tambah kolom pesan & path_foto)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE tamu ADD COLUMN pesan TEXT DEFAULT ''");
      await db.execute("ALTER TABLE tamu ADD COLUMN path_foto TEXT DEFAULT ''");
    }
  }

  // Insert data tamu
  Future<int> insertTamu(Map<String, dynamic> row) async {
    AppLogger.database('INSERT', table: 'tamu', detail: 'nama=${row['nama']}');
    Database db = await database;
    final id = await db.insert('tamu', row);
    AppLogger.database('INSERT OK', table: 'tamu', detail: 'id=$id');
    return id;
  }

  // Ambil semua data tamu, urut dari terbaru
  Future<List<Map<String, dynamic>>> getAllTamu() async {
    AppLogger.database('SELECT', table: 'tamu', detail: 'getAllTamu');
    Database db = await database;
    final results = await db.query('tamu', orderBy: 'tanggal_waktu DESC');
    AppLogger.database('SELECT OK', table: 'tamu', detail: '${results.length} rows');
    return results;
  }

  // Cari data tamu berdasarkan nama
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
}
