import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:attendance_app/models/upload_entry.dart';

class UploadEntryDB {
  static final UploadEntryDB _instance = UploadEntryDB._internal();
  factory UploadEntryDB() => _instance;
  UploadEntryDB._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'upload_entries.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE upload_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        slotLabel TEXT,
        slotStart TEXT,
        slotEnd TEXT,
        status TEXT,
        imagePath TEXT,
        latitude REAL,
        longitude REAL,
        isSynced INTEGER
      )
    ''');
  }

  Future<int> insertEntry(UploadEntry entry) async {
    final database = await db;
    return await database.insert(
      'upload_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UploadEntry>> getEntriesForDate(DateTime date) async {
    final database = await db;
    final formatted = date.toIso8601String().substring(0, 10); // yyyy-MM-dd
    final result = await database.query(
      'upload_entries',
      where: 'date = ?',
      whereArgs: [formatted],
    );
    return result.map((e) => UploadEntry.fromMap(e)).toList();
  }

  Future<int> updateEntry(UploadEntry entry) async {
    final database = await db;
    if (entry.id == null) throw Exception("Cannot update entry without ID");
    return await database.update(
      'upload_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteAllEntries() async {
    final database = await db;
    await database.delete('upload_entries');
  }

  Future<void> deleteEntriesByDate(DateTime date) async {
    final database = await db;
    final formatted = date.toIso8601String().substring(0, 10);
    await database.delete(
      'upload_entries',
      where: 'date = ?',
      whereArgs: [formatted],
    );
  }
}
