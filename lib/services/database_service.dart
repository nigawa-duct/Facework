import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/employee.dart';
import '../models/attendance.dart';

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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE employees(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  faceData TEXT NOT NULL,
  faceEmbedding TEXT
)
''');

        await db.execute('''
CREATE TABLE attendance(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  employeeId INTEGER NOT NULL,
  type TEXT NOT NULL,
  dateTime TEXT NOT NULL
)
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE employees ADD COLUMN faceEmbedding TEXT');
        }
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

  Future<int> insertAttendance(Attendance attendance) async {
    final db = await database;
    return db.insert('attendance', attendance.toMap());
  }

  Future<List<Attendance>> getAttendance() async {
    final db = await database;

    final result = await db.query(
      'attendance',
      orderBy: 'dateTime DESC',
    );

    return result.map((e) => Attendance.fromMap(e)).toList();
  }
}