import 'dart:async';
import 'package:vogu_health/core/storage/local_storage_service.dart';
import 'package:vogu_health/core/interfaces/api_client.dart';
import 'package:vogu_health/models/api_models.dart';
import 'package:vogu_health/core/config/app_config.dart';

class SyncService {
  final LocalStorageService _storage;
  final ApiClient _apiClient;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService(this._storage, this._apiClient);

  Future<void> startPeriodicSync() async {
    if (_syncTimer != null) return;
    
    _syncTimer = Timer.periodic(
      AppConfig.syncInterval,
      (_) => syncPendingData(),
    );
  }

  Future<void> stopPeriodicSync() async {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> syncPendingData() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      await Future.wait([
        _syncSleepData(),
        _syncHeartRateData(),
        _syncWeightData(),
      ]);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncSleepData() async {
    final pendingData = await _storage.getPendingSleepData();
    
    for (final data in pendingData) {
      try {
        final request = SleepDataRequest(
          startTime: data['start_time'],
          endTime: data['end_time'],
          quality: data['quality'],
          phases: SleepPhases.fromJson(data['phases']),
          source: data['source'],
        );

        await _apiClient.submitSleepData(
          startTime: DateTime.parse(request.startTime),
          endTime: DateTime.parse(request.endTime),
          quality: request.quality,
          phases: request.phases,
          source: request.source,
        );

        await _storage.updateSyncStatus('sleep_data', data['id'], 'synced');
      } catch (e) {
        await _storage.addToSyncQueue(
          'sleep_data',
          data['id'],
          'insert',
          data,
        );
      }
    }
  }

  Future<void> _syncHeartRateData() async {
    final pendingData = await _storage.getPendingHeartRateData();
    
    for (final data in pendingData) {
      try {
        final request = HeartRateDataRequest(
          timestamp: data['timestamp'],
          value: data['value'],
          restingRate: data['resting_rate'],
          activityType: data['activity_type'],
          source: data['source'],
        );

        await _apiClient.submitHeartRateData(
          timestamp: DateTime.parse(request.timestamp),
          value: request.value,
          restingRate: request.restingRate,
          activityType: request.activityType,
          source: request.source,
        );

        await _storage.updateSyncStatus('heart_rate_data', data['id'], 'synced');
      } catch (e) {
        await _storage.addToSyncQueue(
          'heart_rate_data',
          data['id'],
          'insert',
          data,
        );
      }
    }
  }

  Future<void> _syncWeightData() async {
    final pendingData = await _storage.getPendingWeightData();
    
    for (final data in pendingData) {
      try {
        final request = WeightDataRequest(
          timestamp: data['timestamp'],
          value: data['value'],
          bmi: data['bmi'],
          bodyComposition: data['body_fat'] != null ? BodyComposition(
            bodyFat: data['body_fat'],
            muscleMass: data['muscle_mass'],
            waterPercentage: data['water_percentage'],
            boneMass: data['bone_mass'],
          ) : null,
          source: data['source'],
        );

        await _apiClient.submitWeightData(
          timestamp: DateTime.parse(request.timestamp),
          value: request.value,
          bmi: request.bmi,
          bodyComposition: request.bodyComposition,
          source: request.source,
        );

        await _storage.updateSyncStatus('weight_data', data['id'], 'synced');
      } catch (e) {
        await _storage.addToSyncQueue(
          'weight_data',
          data['id'],
          'insert',
          data,
        );
      }
    }
  }

  Future<void> retryFailedSyncs() async {
    final queue = await _storage.getSyncQueue();
    
    for (final item in queue) {
      if (item['retry_count'] >= AppConfig.maxSyncRetries) {
        await _storage.removeFromSyncQueue(item['id']);
        continue;
      }

      try {
        switch (item['table_name']) {
          case 'heart_rate_data':
            await _syncHeartRateData();
            break;
          case 'weight_data':
            await _syncWeightData();
            break;
        }
        await _storage.removeFromSyncQueue(item['id']);
      } catch (e) {
        await _storage.incrementRetryCount(item['id']);
      }
    }
  }

  Future<void> cleanupOldData() async {
    await _storage.clearOldData(const Duration(days: 30));
  }
} 