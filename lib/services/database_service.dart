import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/employee.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    return openDatabase(
      join(dbPath, 'facework.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE employees(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            faceData TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE attendance(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employeeId INTEGER,
            type TEXT,
            dateTime TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertEmployee(Employee employee) async {
    final db = await database;
    return db.insert('employees', employee.toMap());
  }

  Future<List<Employee>> getEmployees() async {
    final db = await database;

    final result = await db.query('employees');

    return result.map((e) => Employee.fromMap(e)).toList();
  }
    Future<int> insertAttendance({
    required int employeeId,
    required String type,
  }) async {
    final db = await database;

    return db.insert(
      'attendance',
      {
        'employeeId': employeeId,
        'type': type,
        'dateTime': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAttendance() async {
    final db = await database;

    return db.query(
      'attendance',
      orderBy: 'dateTime DESC',
    );
  }
}