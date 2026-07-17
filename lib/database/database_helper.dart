import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

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
        version: 1,
        onCreate: _onCreate,
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
        path_tanda_tangan TEXT
      )
    ''');
  }

  // Insert data tamu
  Future<int> insertTamu(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('tamu', row);
  }

  // Ambil semua data tamu, urut dari terbaru
  Future<List<Map<String, dynamic>>> getAllTamu() async {
    Database db = await database;
    return await db.query('tamu', orderBy: 'tanggal_waktu DESC');
  }

  // Cari data tamu berdasarkan nama
  Future<List<Map<String, dynamic>>> searchTamu(String keyword) async {
    Database db = await database;
    return await db.query(
      'tamu',
      where: 'nama LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'tanggal_waktu DESC',
    );
  }
}
