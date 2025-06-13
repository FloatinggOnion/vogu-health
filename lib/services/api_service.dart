import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:vogu_health/models/health_data.dart' as health_data;
import 'package:vogu_health/models/health_insight.dart' as insight;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vogu_health/services/storage_service.dart'; // Assuming StorageService handles Hive init and box access

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

class NoDataException extends ApiException {
  NoDataException(DateTime start, DateTime end)
      : super('No data available for the selected period (${start.toIso8601String()} to ${end.toIso8601String()})',
            statusCode: 404);
}

class InvalidDateRangeException extends ApiException {
  InvalidDateRangeException()
      : super('Invalid date range. End date must be after start date.');
}

class FutureDateException extends ApiException {
  FutureDateException()
      : super('Cannot fetch data for future dates.');
}

class DateRangeTooLargeException extends ApiException {
  DateRangeTooLargeException(int maxDays)
      : super('Date range too large. Maximum allowed range is $maxDays days.');
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message, int statusCode) : super(message, statusCode: statusCode);
}

class ClientException extends ApiException {
  ClientException(String message, int statusCode) : super(message, statusCode: statusCode);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class ApiService {
  // Using Android emulator's special host address (10.0.2.2) to access host machine
  // Using machine's IP address on the same subnet as the tablet
  static const String baseUrl = 'https://rotten-women-yawn.loca.lt/api/v1';
  static const int maxDateRangeDays = 365;
  static const Duration timeout = Duration(seconds: 60); // Increased timeout for better reliability
  
  // API Endpoints - Updated to match actual API endpoints
  static const String _sleepEndpoint = '/health-data/sleep';
  static const String _heartRateEndpoint = '/health-data/heart-rate'; // Fixed: was heart_rate
  static const String _weightEndpoint = '/health-data/weight';
  static const String _insightsEndpoint = '/insights/recent'; // Fixed: was /insights
  static const String _dailyInsightsEndpoint = '/insights/daily';
  
  // Generic endpoints for data retrieval
  static const String _healthDataEndpoint = '/health-data';
  static const String _dailyHealthDataEndpoint = '/health-data/daily';
  
  final http.Client _client;
  final Box<dynamic> _cacheBox;
  final StorageService _storageService;
  bool _isOnline = true;

  ApiService(this._client, this._cacheBox, this._storageService);

  // Network status
  bool get isOnline => _isOnline;
  set isOnline(bool value) => _isOnline = value;

  // Helper to get a Hive box, ensuring it's open and types are registered
  Future<Box<T>> _getBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      // Ensure adapters are registered before opening the box
      if (!Hive.isAdapterRegistered(health_data.SleepDataAdapter().typeId)) 
        Hive.registerAdapter(health_data.SleepDataAdapter());
      if (!Hive.isAdapterRegistered(health_data.SleepPhasesAdapter().typeId)) 
        Hive.registerAdapter(health_data.SleepPhasesAdapter());
      if (!Hive.isAdapterRegistered(health_data.HeartRateDataAdapter().typeId)) 
        Hive.registerAdapter(health_data.HeartRateDataAdapter());
      if (!Hive.isAdapterRegistered(health_data.BodyCompositionAdapter().typeId)) 
        Hive.registerAdapter(health_data.BodyCompositionAdapter());
      if (!Hive.isAdapterRegistered(health_data.WeightDataAdapter().typeId)) 
        Hive.registerAdapter(health_data.WeightDataAdapter());
      if (!Hive.isAdapterRegistered(insight.HealthInsightAdapter().typeId)) 
        Hive.registerAdapter(insight.HealthInsightAdapter());

      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }

  void _validateDateRange(DateTime startDate, DateTime endDate) {
    final now = DateTime.now();
    
    if (endDate.isAfter(now)) {
      throw FutureDateException();
    }
    
    if (endDate.isBefore(startDate)) {
      throw InvalidDateRangeException();
    }
    
    final difference = endDate.difference(startDate).inDays;
    if (difference > maxDateRangeDays) {
      throw DateRangeTooLargeException(maxDateRangeDays);
    }
  }

  // Helper method for making API requests with proper error handling and retry logic
  Future<T> _makeRequest<T>({
    required String endpoint,
    required String method,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    String? cacheKey,
    bool useCache = true,
    int maxRetries = 3,
  }) async {
    if (!_isOnline && useCache) {
      final cachedData = _cacheBox.get(cacheKey);
      if (cachedData != null) {
        try {
          return fromJson(json.decode(cachedData));
        } catch (e) {
          _cacheBox.delete(cacheKey);
          throw CacheException('Invalid cached data format: $e');
        }
      }
      throw NetworkException('Device is offline and no cached data available');
    }

    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
        final request = http.Request(method, uri);
        
        if (body != null) {
          request.headers['Content-Type'] = 'application/json';
          request.body = json.encode(body);
        }

        print('Making $method request to: $uri');
        if (body != null) {
          print('Request body: ${json.encode(body)}');
        }

        final streamedResponse = await _client.send(request).timeout(timeout);
        final response = await http.Response.fromStream(streamedResponse);

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = json.decode(response.body);
          final result = fromJson(data);
          
          if (useCache && cacheKey != null) {
            _cacheBox.put(cacheKey, response.body);
          }
          
          return result;
        } else if (response.statusCode == 404) {
          throw NoDataException(DateTime.now(), DateTime.now());
        } else if (response.statusCode >= 500) {
          throw ServerException('Server error: ${response.statusCode}', response.statusCode);
        } else if (response.statusCode == 408) {
          // Timeout error - retry with exponential backoff
          retryCount++;
          if (retryCount < maxRetries) {
            final delay = Duration(seconds: retryCount * 2); // Exponential backoff: 2s, 4s, 6s
            print('Request timed out, retrying in ${delay.inSeconds} seconds... (attempt $retryCount/$maxRetries)');
            await Future.delayed(delay);
            continue;
          } else {
            throw ApiException('Request timed out after $maxRetries attempts. Please check your connection and try again.', statusCode: 408);
          }
        } else {
          throw ClientException('Client error: ${response.statusCode}', response.statusCode);
        }
      } on TimeoutException {
        retryCount++;
        if (retryCount < maxRetries) {
          final delay = Duration(seconds: retryCount * 2);
          print('Request timed out, retrying in ${delay.inSeconds} seconds... (attempt $retryCount/$maxRetries)');
          await Future.delayed(delay);
          continue;
        } else {
          throw ApiException('Request timed out after $maxRetries attempts. Please check your connection and try again.', statusCode: 408);
        }
      } on FormatException {
        throw ApiException('Invalid response format from server', statusCode: 400);
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Request failed: $e', statusCode: 500);
      }
    }
    
    throw ApiException('Request failed after $maxRetries attempts', statusCode: 500);
  }

  // Data Submission Methods - Updated with correct endpoints and better error handling
  Future<void> submitSleepData(health_data.SleepData data) async {
    try {
      // Add required fields that the backend expects
      final enhancedData = {
        'start_time': data.startTime.toIso8601String(),
        'end_time': data.endTime.toIso8601String(),
        'quality': data.quality,
        'phases': data.phases.toJson(),
        'source': 'mobile_app',
        'user_id': 'default_user',
      };
      
      await _makeRequest<void>(
        endpoint: _sleepEndpoint,
        method: 'POST',
        fromJson: (_) => null,
        body: enhancedData,
        cacheKey: 'sleep_${data.startTime.toIso8601String()}',
        useCache: false,
      );
      print('Sleep data submitted successfully: ${enhancedData}');
    } catch (e) {
      print('Error submitting sleep data: $e');
      rethrow;
    }
  }

  Future<void> submitHeartRateData(health_data.HeartRateData data) async {
    try {
      // Add required fields that the backend expects
      final enhancedData = {
        'timestamp': data.timestamp.toIso8601String(),
        'value': data.value,
        'resting_rate': data.restingRate,
        'activity_type': data.activityType,
        'source': 'mobile_app',
        'user_id': 'default_user',
      };
      
      await _makeRequest<void>(
        endpoint: _heartRateEndpoint,
        method: 'POST',
        fromJson: (_) => null,
        body: enhancedData,
        cacheKey: 'heart_rate_${data.timestamp.toIso8601String()}',
        useCache: false,
      );
      print('Heart rate data submitted successfully: ${enhancedData}');
    } catch (e) {
      print('Error submitting heart rate data: $e');
      rethrow;
    }
  }

  Future<void> submitWeightData(health_data.WeightData data) async {
    try {
      // Create a simplified weight data object without body_composition
      // since the backend doesn't support MetricType.BODY_COMPOSITION
      // Also handle null values properly to avoid type casting errors
      final simplifiedData = <String, dynamic>{
        'timestamp': data.timestamp.toIso8601String(),
        'value': data.value,
        'source': 'mobile_app',
        'user_id': 'default_user', // Add required user_id field
      };
      
      // Only include bmi if it's not null to avoid type casting errors
      if (data.bmi != null) {
        simplifiedData['bmi'] = data.bmi;
      }
      
      // Exclude body_composition to avoid backend errors
      // 'body_composition': data.bodyComposition?.toJson(),
      
      await _makeRequest<void>(
        endpoint: _weightEndpoint,
        method: 'POST',
        fromJson: (_) => null,
        body: simplifiedData,
        cacheKey: 'weight_${data.timestamp.toIso8601String()}',
        useCache: false,
      );
      print('Weight data submitted successfully (without body composition): ${simplifiedData}');
    } catch (e) {
      print('Error submitting weight data: $e');
      rethrow;
    }
  }

  // Data Retrieval Methods - Updated to handle backend errors gracefully
  Future<List<health_data.SleepData>> getSleepData({int days = 7}) async {
    try {
      return await _makeRequest<List<health_data.SleepData>>(
        endpoint: _sleepEndpoint,
        method: 'GET',
        fromJson: (json) => (json['data'] as List)
            .map((item) => health_data.SleepData.fromJson(item as Map<String, dynamic>))
            .toList(),
        queryParams: {'days': days.toString()},
        cacheKey: 'sleep_data_$days',
      );
    } catch (e) {
      print('Error fetching sleep data: $e');
      // Return empty list instead of throwing to prevent app crashes
      return [];
    }
  }

  Future<List<health_data.HeartRateData>> getHeartRateData({int days = 7}) async {
    try {
      return await _makeRequest<List<health_data.HeartRateData>>(
        endpoint: _heartRateEndpoint,
        method: 'GET',
        fromJson: (json) => (json['data'] as List)
            .map((item) => health_data.HeartRateData.fromJson(item as Map<String, dynamic>))
            .toList(),
        queryParams: {'days': days.toString()},
        cacheKey: 'heart_rate_data_$days',
      );
    } catch (e) {
      print('Error fetching heart rate data: $e');
      // Return empty list instead of throwing to prevent app crashes
      return [];
    }
  }

  Future<List<health_data.WeightData>> getWeightData({int days = 7}) async {
    try {
      return await _makeRequest<List<health_data.WeightData>>(
        endpoint: _weightEndpoint,
        method: 'GET',
        fromJson: (json) => (json['data'] as List)
            .map((item) => health_data.WeightData.fromJson(item as Map<String, dynamic>))
            .toList(),
        queryParams: {'days': days.toString()},
        cacheKey: 'weight_data_$days',
      );
    } catch (e) {
      print('Error fetching weight data: $e');
      // Return empty list instead of throwing to prevent app crashes
      return [];
    }
  }

  Future<health_data.HealthMetrics> getDailyMetrics(DateTime date) async {
    final cacheKey = 'daily_metrics_${date.toIso8601String()}';
    
    final sleepData = await _makeRequest<List<health_data.SleepData>>(
      endpoint: '$_sleepEndpoint/daily/${date.toIso8601String()}',
      method: 'GET',
      fromJson: (json) => (json['data'] as List)
          .map((item) => health_data.SleepData.fromJson(item as Map<String, dynamic>))
          .toList(),
      cacheKey: '${cacheKey}_sleep',
    );

    final heartRateData = await _makeRequest<List<health_data.HeartRateData>>(
      endpoint: '$_heartRateEndpoint/daily/${date.toIso8601String()}',
      method: 'GET',
      fromJson: (json) => (json['data'] as List)
          .map((item) => health_data.HeartRateData.fromJson(item as Map<String, dynamic>))
          .toList(),
      cacheKey: '${cacheKey}_heart_rate',
    );

    final weightData = await _makeRequest<List<health_data.WeightData>>(
      endpoint: '$_weightEndpoint/daily/${date.toIso8601String()}',
      method: 'GET',
      fromJson: (json) => (json['data'] as List)
          .map((item) => health_data.WeightData.fromJson(item as Map<String, dynamic>))
          .toList(),
      cacheKey: '${cacheKey}_weight',
    );

    return health_data.HealthMetrics(
      sleep: sleepData,
      heartRate: heartRateData,
      weight: weightData,
    );
  }

  // Insights Methods - Updated with better error handling
  Future<List<insight.HealthInsight>> getRecentInsights({int days = 7}) async {
    try {
      return await _makeRequest<List<insight.HealthInsight>>(
        endpoint: _insightsEndpoint,
        method: 'GET',
        fromJson: (json) => (json['data'] as List)
            .map((item) => insight.HealthInsight.fromJson(item as Map<String, dynamic>))
            .toList(),
        queryParams: {'days': days.toString()},
        cacheKey: 'insights_$days',
      );
    } catch (e) {
      print('Error fetching recent insights: $e');
      // Return empty list instead of throwing to prevent app crashes
      // The backend has issues with BODY_COMPOSITION metric type
      return [];
    }
  }

  Future<List<insight.HealthInsight>> getDailyInsights(DateTime date) async {
    try {
      return await _makeRequest<List<insight.HealthInsight>>(
        endpoint: '$_dailyInsightsEndpoint/${date.toIso8601String()}',
        method: 'GET',
        fromJson: (json) => (json['data'] as List)
            .map((item) => insight.HealthInsight.fromJson(item as Map<String, dynamic>))
            .toList(),
        cacheKey: 'insights_daily_${date.toIso8601String()}',
      );
    } catch (e) {
      print('Error fetching daily insights: $e');
      // Return empty list instead of throwing to prevent app crashes
      return [];
    }
  }

  // Legacy methods for backward compatibility
  @Deprecated('Use getSleepData, getHeartRateData, and getWeightData instead')
  Future<health_data.HealthMetrics> getMetricsByDateRange(DateTime startDate, DateTime endDate) async {
    _validateDateRange(startDate, endDate);
    
    final days = endDate.difference(startDate).inDays;
    final sleepData = await getSleepData(days: days);
    final heartRateData = await getHeartRateData(days: days);
    final weightData = await getWeightData(days: days);

    return health_data.HealthMetrics(
      sleep: sleepData,
      heartRate: heartRateData,
      weight: weightData,
    );
  }

  // Clear cache for specific data type
  void clearCache(String prefix) {
    final keysToDelete = _cacheBox.keys
        .where((key) => key.toString().startsWith(prefix))
        .toList();
    _cacheBox.deleteAll(keysToDelete);
  }

  // Clear all cache
  void clearAllCache() {
    _cacheBox.clear();
  }

  // Clear problematic cached data that might contain body composition
  Future<void> clearProblematicCache() async {
    try {
      // Clear all cache to remove any data with body composition
      _cacheBox.clear();
      
      // Also clear any Hive boxes that might contain problematic data
      final boxes = ['sleep_data', 'heart_rate_data', 'weight_data', 'insights'];
      for (final boxName in boxes) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        }
      }
      
      print('Cleared all cached data to remove potential body composition conflicts');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Test API connectivity
  Future<bool> testConnection() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 10));
      
      print('API health check response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('API health check failed: $e');
      return false;
    }
  }

  // Get detailed connection info for debugging
  Future<Map<String, dynamic>> getConnectionInfo() async {
    final info = <String, dynamic>{
      'baseUrl': baseUrl,
      'isOnline': _isOnline,
      'timeout': timeout.inSeconds,
    };
    
    try {
      final isHealthy = await testConnection();
      info['apiHealthy'] = isHealthy;
    } catch (e) {
      info['apiHealthy'] = false;
      info['error'] = e.toString();
    }
    
    return info;
  }

  // --- Error Handling ---
  void _handleError(dynamic error, String source) {
    print('Error in $source: $error');
    if (error is http.ClientException) {
      throw NetworkException(error.message); // Convert http client exception to custom NetworkException
    } else if (error is http.Response) { // Handle errors from http responses (non-2xx status codes)
        throw ServerException(error.body, error.statusCode); // Convert http response error to custom ServerException
    } else if (error is ApiException) {
        throw error; // Re-throw custom API exceptions
    } else {
        throw ApiException('An unexpected error occurred: ${error.toString()}'); // Wrap other errors in a generic ApiException
    }
  }
} 