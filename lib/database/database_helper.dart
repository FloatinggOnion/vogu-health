import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static bool _isInitialized = false;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    if (!_isInitialized) {
      if (kIsWeb) {
        // Initialize for web platform
        databaseFactory = databaseFactoryFfiWeb;
      } else if (Platform.isAndroid) {
        // Initialize for Android with proper library loading
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } else if (Platform.isIOS) {
        // Initialize for iOS
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } else {
        // Initialize for desktop platforms
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      _isInitialized = true;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (kIsWeb) {
      path = 'vogu_health.db';
    } else {
      path = join(await getDatabasesPath(), 'vogu_health.db');
    }

    try {
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) async {
          try {
            await db.execute('SELECT 1 FROM health_data LIMIT 1');
          } catch (e) {
            print('Database verification failed, recreating tables: $e');
            await _onCreate(db, 1);
          }
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      // If initialization fails, try to delete and recreate the database
      if (kIsWeb) {
        await databaseFactoryFfiWeb.deleteDatabase(path);
      } else {
        await deleteDatabase(path);
      }
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // Health data table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS health_data(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          hrv REAL,
          stress_level INTEGER,
          heart_rate INTEGER,
          sleep_hours REAL,
          steps INTEGER,
          calories_burned INTEGER,
          created_at TEXT NOT NULL
        )
      ''');

      // Feedback table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS feedback(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          category TEXT NOT NULL,
          content TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    } catch (e) {
      print('Error creating tables: $e');
      rethrow;
    }
  }

  // Insert health data
  Future<int> insertHealthData(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert('health_data', row);
    } catch (e) {
      print('Error inserting health data: $e');
      // Try to recreate the database if the error persists
      if (kIsWeb) {
        await _resetDatabase();
        Database db = await database;
        return await db.insert('health_data', row);
      }
      rethrow;
    }
  }

  // Get health data for a specific date range
  Future<List<Map<String, dynamic>>> getHealthDataByDateRange(
      String startDate, String endDate) async {
    try {
      Database db = await database;
      return await db.query(
        'health_data',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startDate, endDate],
        orderBy: 'date DESC',
      );
    } catch (e) {
      print('Error getting health data: $e');
      // Try to recreate the database if the error persists
      if (kIsWeb) {
        await _resetDatabase();
        Database db = await database;
        return await db.query(
          'health_data',
          where: 'date BETWEEN ? AND ?',
          whereArgs: [startDate, endDate],
          orderBy: 'date DESC',
        );
      }
      rethrow;
    }
  }

  // Insert feedback
  Future<int> insertFeedback(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert('feedback', row);
    } catch (e) {
      print('Error inserting feedback: $e');
      // Try to recreate the database if the error persists
      if (kIsWeb) {
        await _resetDatabase();
        Database db = await database;
        return await db.insert('feedback', row);
      }
      rethrow;
    }
  }

  // Get feedback by category
  Future<List<Map<String, dynamic>>> getFeedbackByCategory(
      String category) async {
    try {
      Database db = await database;
      return await db.query(
        'feedback',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'date DESC',
      );
    } catch (e) {
      print('Error getting feedback: $e');
      // Try to recreate the database if the error persists
      if (kIsWeb) {
        await _resetDatabase();
        Database db = await database;
        return await db.query(
          'feedback',
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'date DESC',
        );
      }
      rethrow;
    }
  }

  // Reset database (for web platform)
  Future<void> _resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    if (kIsWeb) {
      String path = 'vogu_health.db';
      await databaseFactoryFfiWeb.deleteDatabase(path);
    }
    _database = await _initDatabase();
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
} 