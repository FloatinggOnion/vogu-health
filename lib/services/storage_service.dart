import 'package:hive_flutter/hive_flutter.dart';
import '../models/health_data.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static Box<HealthData>? _healthDataBox;
  static Box<String>? _feedbackBox;

  factory StorageService() => _instance;

  StorageService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HealthDataAdapter());
    }
    
    // Open boxes
    _healthDataBox = await Hive.openBox<HealthData>('health_data');
    _feedbackBox = await Hive.openBox<String>('feedback');
  }

  // Health Data Operations
  Future<void> insertHealthData(HealthData data) async {
    await _healthDataBox?.add(data);
  }

  Future<List<HealthData>> getHealthDataByDateRange(
      String startDate, String endDate) async {
    final allData = _healthDataBox?.values.toList() ?? [];
    return allData
        .where((data) => data.date.compareTo(startDate) >= 0 &&
            data.date.compareTo(endDate) <= 0)
        .toList();
  }

  // Feedback Operations
  Future<void> insertFeedback(String category, String content) async {
    final key = '${DateTime.now().toIso8601String()}_$category';
    await _feedbackBox?.put(key, content);
  }

  Future<List<String>> getFeedbackByCategory(String category) async {
    final allKeys = _feedbackBox?.keys.toList() ?? [];
    final feedback = <String>[];
    
    for (final key in allKeys) {
      if (key.toString().endsWith('_$category')) {
        final content = _feedbackBox?.get(key);
        if (content != null) {
          feedback.add(content);
        }
      }
    }
    
    return feedback;
  }

  Future<void> close() async {
    await _healthDataBox?.close();
    await _feedbackBox?.close();
  }
} 