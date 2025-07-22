import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:attendance_app/models/user_model.dart';

class UserDb {
  static final UserDb _instance = UserDb._internal();
  factory UserDb() => _instance;
  UserDb._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'user_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        userId TEXT,
        designation TEXT,
        officerType TEXT,
        mobile TEXT,
        boothNumber TEXT,
        boothName TEXT
      )
    ''');
  }

  Future<int> insertUser(UserModel user) async {
    final database = await db;

    await database.delete('user');

    return await database.insert(
      'user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser() async {
    final database = await db;
    final result = await database.query('user', limit: 1);
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> deleteUser() async {
    final database = await db;
    await database.delete('user');
  }
}
