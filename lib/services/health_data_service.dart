import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/health_data.dart' as health_data;
import '../models/health_insight.dart' as insight;
import 'storage_service.dart';
import 'api_service.dart';

enum DataStatus {
  initial,
  loading,
  loaded,
  error,
  offline
}

class HealthDataService extends ChangeNotifier {
  final StorageService _storage;
  final ApiService _apiService;
  
  // State
  DataStatus _status = DataStatus.initial;
  String? _error;
  bool _isOnline = true;
  
  // Data
  List<health_data.SleepData> _sleepData = [];
  List<health_data.HeartRateData> _heartRateData = [];
  List<health_data.WeightData> _weightData = [];
  List<insight.HealthInsight> _insights = [];
  
  // Offline storage boxes
  static Box<health_data.SleepData>? _sleepBox;
  static Box<health_data.HeartRateData>? _heartRateBox;
  static Box<health_data.WeightData>? _weightBox;
  static Box<insight.HealthInsight>? _insightsBox;
  static Box<Map<String, dynamic>>? _pendingSyncBox;

  // Pending sync queue
  List<Map<String, dynamic>> _pendingSync = [];

  // Getters
  DataStatus get status => _status;
  String? get error => _error;
  bool get isOnline => _isOnline;
  List<health_data.SleepData> get sleepData => _sleepData;
  List<health_data.HeartRateData> get heartRateData => _heartRateData;
  List<health_data.WeightData> get weightData => _weightData;
  List<insight.HealthInsight> get insights => _insights;

  HealthDataService(this._storage, this._apiService) {
    _apiService.isOnline = _isOnline;
    _initStorage();
  }

  // Initialize storage
  Future<void> _initStorage() async {
    try {
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(health_data.SleepDataAdapter().typeId)) {
        Hive.registerAdapter(health_data.SleepDataAdapter());
      }
      if (!Hive.isAdapterRegistered(health_data.HeartRateDataAdapter().typeId)) {
        Hive.registerAdapter(health_data.HeartRateDataAdapter());
      }
      if (!Hive.isAdapterRegistered(health_data.WeightDataAdapter().typeId)) {
        Hive.registerAdapter(health_data.WeightDataAdapter());
      }
      if (!Hive.isAdapterRegistered(insight.HealthInsightAdapter().typeId)) {
        Hive.registerAdapter(insight.HealthInsightAdapter());
      }

      // Open boxes
      _sleepBox = await Hive.openBox<health_data.SleepData>('sleep_data');
      _heartRateBox = await Hive.openBox<health_data.HeartRateData>('heart_rate_data');
      _weightBox = await Hive.openBox<health_data.WeightData>('weight_data');
      _insightsBox = await Hive.openBox<insight.HealthInsight>('insights');
      _pendingSyncBox = await Hive.openBox<Map<String, dynamic>>('pending_sync');

      // Load pending sync
      _loadPendingSync();
    } catch (e) {
      print('Error initializing storage: $e');
    }
  }

  // Load pending sync queue from storage
  Future<void> _loadPendingSync() async {
    try {
      _pendingSync = _pendingSyncBox?.values.toList() ?? [];
    } catch (e) {
      print('Error loading pending sync: $e');
    }
  }

  // Save pending sync queue to storage
  Future<void> _savePendingSync() async {
    try {
      await _pendingSyncBox?.clear();
      for (final item in _pendingSync) {
        await _pendingSyncBox?.add(item);
      }
    } catch (e) {
      print('Error saving pending sync: $e');
    }
  }

  // Add data to pending sync queue
  void _addToPendingSync(String type, Map<String, dynamic> data) {
    _pendingSync.add({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _savePendingSync();
  }

  // Process pending sync queue
  Future<void> _processPendingSync() async {
    if (_pendingSync.isEmpty) return;

    final failedSync = <Map<String, dynamic>>[];
    
    for (final item in _pendingSync) {
      try {
        switch (item['type']) {
          case 'sleep':
            await _apiService.submitSleepData(
              health_data.SleepData.fromJson(item['data'])
            );
            break;
          case 'heart_rate':
            await _apiService.submitHeartRateData(
              health_data.HeartRateData.fromJson(item['data'])
            );
            break;
          case 'weight':
            await _apiService.submitWeightData(
              health_data.WeightData.fromJson(item['data'])
            );
            break;
        }
      } catch (e) {
        print('Error syncing item: $e');
        failedSync.add(item);
      }
    }

    _pendingSync = failedSync;
    await _savePendingSync();
  }

  // Update online status
  void updateOnlineStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _apiService.isOnline = isOnline;
      notifyListeners();
      
      if (isOnline) {
        syncData();
      }
    }
  }

  // Override loadData to handle offline storage
  @override
  Future<void> loadData({int days = 7}) async {
    try {
      _status = DataStatus.loading;
      _error = null;
      notifyListeners();

      if (_isOnline) {
        // Load data in parallel
        final results = await Future.wait([
          _apiService.getSleepData(days: days),
          _apiService.getHeartRateData(days: days),
          _apiService.getWeightData(days: days),
          _apiService.getRecentInsights(days: days),
        ]);

        _sleepData = results[0] as List<health_data.SleepData>;
        _heartRateData = results[1] as List<health_data.HeartRateData>;
        _weightData = results[2] as List<health_data.WeightData>;
        _insights = results[3] as List<insight.HealthInsight>;

        // Save to local storage
        final clearFutures = <Future<void>>[];
        if (_sleepBox != null) clearFutures.add(_sleepBox!.clear());
        if (_heartRateBox != null) clearFutures.add(_heartRateBox!.clear());
        if (_weightBox != null) clearFutures.add(_weightBox!.clear());
        if (_insightsBox != null) clearFutures.add(_insightsBox!.clear());
        await Future.wait<void>(clearFutures);

        // Add data to boxes
        final addFutures = <Future<void>>[];
        for (final data in _sleepData) {
          if (_sleepBox != null) addFutures.add(_sleepBox!.add(data));
        }
        for (final data in _heartRateData) {
          if (_heartRateBox != null) addFutures.add(_heartRateBox!.add(data));
        }
        for (final data in _weightData) {
          if (_weightBox != null) addFutures.add(_weightBox!.add(data));
        }
        for (final data in _insights) {
          if (_insightsBox != null) addFutures.add(_insightsBox!.add(data));
        }
        await Future.wait<void>(addFutures);
      } else {
        // Load from local storage
        _sleepData = _sleepBox?.values.toList() ?? [];
        _heartRateData = _heartRateBox?.values.toList() ?? [];
        _weightData = _weightBox?.values.toList() ?? [];
        _insights = _insightsBox?.values.toList() ?? [];
      }

      _status = DataStatus.loaded;
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  // Load daily data
  Future<void> loadDailyData(DateTime date) async {
    try {
      _status = DataStatus.loading;
      _error = null;
      notifyListeners();

      final metrics = await _apiService.getDailyMetrics(date);
      final insights = await _apiService.getDailyInsights(date);

      _sleepData = metrics.sleep;
      _heartRateData = metrics.heartRate;
      _weightData = metrics.weight;
      _insights = insights;

      _status = DataStatus.loaded;
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  // Submit new data
  Future<void> submitSleepData(health_data.SleepData data) async {
    try {
      _status = DataStatus.loading;
      notifyListeners();

      if (_isOnline) {
        await _apiService.submitSleepData(data);
      } else {
        _addToPendingSync('sleep', data.toJson());
      }
      
      _sleepData.add(data);
      await _sleepBox?.add(data);
      
      _status = DataStatus.loaded;
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> submitHeartRateData(health_data.HeartRateData data) async {
    try {
      _status = DataStatus.loading;
      notifyListeners();

      if (_isOnline) {
        await _apiService.submitHeartRateData(data);
      } else {
        _addToPendingSync('heart_rate', data.toJson());
      }
      
      _heartRateData.add(data);
      await _heartRateBox?.add(data);
      
      _status = DataStatus.loaded;
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> submitWeightData(health_data.WeightData data) async {
    try {
      _status = DataStatus.loading;
      notifyListeners();

      if (_isOnline) {
        await _apiService.submitWeightData(data);
      } else {
        _addToPendingSync('weight', data.toJson());
      }
      
      _weightData.add(data);
      await _weightBox?.add(data);
      
      _status = DataStatus.loaded;
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  // Sync data when coming back online
  Future<void> syncData() async {
    if (!_isOnline) return;

    try {
      _status = DataStatus.loading;
      notifyListeners();

      // Process any pending sync items
      await _processPendingSync();
      
      // Reload data from server
      await loadData();

      _status = DataStatus.loaded;
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  // Error handling
  void _handleError(dynamic error) {
    if (error is NetworkException) {
      _status = DataStatus.offline;
      _isOnline = false;
      _apiService.isOnline = false;
    } else {
      _status = DataStatus.error;
      _error = error.toString();
    }
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    if (_status == DataStatus.error) {
      _status = DataStatus.initial;
    }
    notifyListeners();
  }
} 