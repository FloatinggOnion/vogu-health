import '../models/health_data.dart';
import 'storage_service.dart';

class HealthDataService {
  final StorageService _storage;
  List<HealthData> _healthDataHistory = [];

  HealthDataService(this._storage);

  Future<void> insertHealthData(HealthData data) async {
    await _storage.insertHealthData(data);
    _healthDataHistory.add(data);
  }

  Future<List<HealthData>> getHealthDataByDateRange(
      String startDate, String endDate) async {
    return await _storage.getHealthDataByDateRange(startDate, endDate);
  }

  Future<void> loadHealthDataHistory() async {
    _healthDataHistory = await getHealthDataByDateRange(
      DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      DateTime.now().toIso8601String(),
    );
  }

  List<HealthData> get healthDataHistory => _healthDataHistory;
} 