import 'package:vogu_health/core/interfaces/local_storage.dart';
import 'package:vogu_health/core/interfaces/network_info.dart';
import 'package:vogu_health/models/api_models.dart';

mixin OfflineRepositoryMixin {
  late final LocalStorage _localStorage;
  late final NetworkInfo _networkInfo;

  void initialize(LocalStorage storage, NetworkInfo networkInfo) {
    _localStorage = storage;
    _networkInfo = networkInfo;
  }

  Future<void> _syncPendingData() async {
    if (await _networkInfo.isConnected) {
      // Implement sync logic here
    }
  }

  Future<T> _handleOfflineOperation<T>({
    required Future<T> Function() onlineOperation,
    required Future<T> Function() offlineOperation,
    required Future<void> Function(dynamic data) saveOffline,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await onlineOperation();
        await saveOffline(result);
        return result;
      } catch (e) {
        return offlineOperation();
      }
    } else {
      return offlineOperation();
    }
  }

  Future<void> _savePendingData(String key, dynamic data) async {
    switch (key) {
      case 'sleep':
        await _localStorage.insertSleepData(data);
        break;
      case 'heart_rate':
        await _localStorage.insertHeartRateData(data);
        break;
      case 'weight':
        await _localStorage.insertWeightData(data);
        break;
    }
  }

  Future<List<T>> _getCachedData<T>(String key) async {
    List<Map<String, dynamic>> data;
    switch (key) {
      case 'sleep':
        data = await _localStorage.getPendingSleepData();
        break;
      case 'heart_rate':
        data = await _localStorage.getPendingHeartRateData();
        break;
      case 'weight':
        data = await _localStorage.getPendingWeightData();
        break;
      default:
        data = [];
    }
    return data.map((e) => T.fromJson(e) as T).toList();
  }

  LocalStorage get storage => _localStorage;
  NetworkInfo get networkInfo => _networkInfo;
} 