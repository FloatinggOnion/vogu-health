import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:vogu_health/models/api_models.dart';

class LocalStorageService {
  static Database? _database;
  static const String _databaseName = 'vogu_health.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _sleepTable = 'sleep_data';
  static const String _heartRateTable = 'heart_rate_data';
  static const String _weightTable = 'weight_data';
  static const String _syncQueueTable = 'sync_queue';

  // Singleton instance
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Sleep data table
    await db.execute('''
      CREATE TABLE $_sleepTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        quality INTEGER NOT NULL,
        phases TEXT NOT NULL,
        source TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Heart rate data table
    await db.execute('''
      CREATE TABLE $_heartRateTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        value INTEGER NOT NULL,
        resting_rate INTEGER,
        activity_type TEXT,
        source TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Weight data table
    await db.execute('''
      CREATE TABLE $_weightTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        value REAL NOT NULL,
        bmi REAL,
        body_fat REAL,
        muscle_mass REAL,
        water_percentage REAL,
        bone_mass REAL,
        source TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE $_syncQueueTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Sleep data operations
  Future<int> insertSleepData(SleepDataRequest data) async {
    final db = await database;
    return await db.insert(_sleepTable, {
      'start_time': data.startTime,
      'end_time': data.endTime,
      'quality': data.quality,
      'phases': data.phases.toJson().toString(),
      'source': data.source,
      'sync_status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSleepData() async {
    final db = await database;
    return await db.query(
      _sleepTable,
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
  }

  // Heart rate data operations
  Future<int> insertHeartRateData(HeartRateDataRequest data) async {
    final db = await database;
    return await db.insert(_heartRateTable, {
      'timestamp': data.timestamp,
      'value': data.value,
      'resting_rate': data.restingRate,
      'activity_type': data.activityType,
      'source': data.source,
      'sync_status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingHeartRateData() async {
    final db = await database;
    return await db.query(
      _heartRateTable,
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
  }

  Future<List<Map<String, dynamic>>> getHeartRateDataByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    return await db.query(
      _heartRateTable,
      where: "timestamp LIKE ?",
      whereArgs: ['$dateStr%'],
    );
  }

  // Weight data operations
  Future<int> insertWeightData(WeightDataRequest data) async {
    final db = await database;
    return await db.insert(_weightTable, {
      'timestamp': data.timestamp,
      'value': data.value,
      'bmi': data.bmi,
      'body_fat': data.bodyComposition?.bodyFat,
      'muscle_mass': data.bodyComposition?.muscleMass,
      'water_percentage': data.bodyComposition?.waterPercentage,
      'bone_mass': data.bodyComposition?.boneMass,
      'source': data.source,
      'sync_status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingWeightData() async {
    final db = await database;
    return await db.query(
      _weightTable,
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
  }

  Future<List<Map<String, dynamic>>> getWeightDataByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    return await db.query(
      _weightTable,
      where: "timestamp LIKE ?",
      whereArgs: ['$dateStr%'],
    );
  }

  // Sync queue operations
  Future<void> updateSyncStatus(String tableName, int recordId, String status) async {
    final db = await database;
    await db.update(
      tableName,
      {'sync_status': status},
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  Future<void> addToSyncQueue(String tableName, int recordId, String operation, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(_syncQueueTable, {
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': data.toString(),
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query(
      _syncQueueTable,
      orderBy: 'created_at ASC',
    );
  }

  Future<void> incrementRetryCount(int queueId) async {
    final db = await database;
    final currentCount = await db.query(
      _syncQueueTable,
      columns: ['retry_count'],
      where: 'id = ?',
      whereArgs: [queueId],
    );
    
    if (currentCount.isNotEmpty) {
      final newCount = (currentCount.first['retry_count'] as int) + 1;
      await db.update(
        _syncQueueTable,
        {'retry_count': newCount},
        where: 'id = ?',
        whereArgs: [queueId],
      );
    }
  }

  Future<void> removeFromSyncQueue(int queueId) async {
    final db = await database;
    await db.delete(
      _syncQueueTable,
      where: 'id = ?',
      whereArgs: [queueId],
    );
  }

  // Cleanup operations
  Future<void> clearOldData(Duration age) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(age).toIso8601String();
    
    await Future.wait([
      db.delete(_sleepTable, where: 'created_at < ?', whereArgs: [cutoffDate]),
      db.delete(_heartRateTable, where: 'created_at < ?', whereArgs: [cutoffDate]),
      db.delete(_weightTable, where: 'created_at < ?', whereArgs: [cutoffDate]),
    ]);
  }
} 