import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:vogu_health/models/health_data.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ApiException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class NoDataException extends ApiException {
  NoDataException(DateTime start, DateTime end)
      : super('No data available for the selected period (${start.toIso8601String()} to ${end.toIso8601String()})',
            code: 'NO_DATA');
}

class InvalidDateRangeException extends ApiException {
  InvalidDateRangeException()
      : super('Invalid date range. End date must be after start date.',
            code: 'INVALID_DATE_RANGE');
}

class FutureDateException extends ApiException {
  FutureDateException()
      : super('Cannot fetch data for future dates.',
            code: 'FUTURE_DATE');
}

class DateRangeTooLargeException extends ApiException {
  DateRangeTooLargeException(int maxDays)
      : super('Date range too large. Maximum allowed range is $maxDays days.',
            code: 'DATE_RANGE_TOO_LARGE');
}

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  static const int maxDateRangeDays = 365;
  static const Duration timeout = Duration(seconds: 30);
  
  final http.Client _client;
  final Box<dynamic> _cacheBox;

  ApiService(this._client, this._cacheBox);

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

  Future<HealthMetrics> getMetricsByDateRange(DateTime startDate, DateTime endDate) async {
    _validateDateRange(startDate, endDate);
    
    final cacheKey = 'metrics_${startDate.toIso8601String()}_${endDate.toIso8601String()}';
    
    // Check cache first
    final cachedData = _cacheBox.get(cacheKey);
    if (cachedData != null) {
      try {
        return HealthMetrics.fromJson(json.decode(cachedData));
      } catch (e) {
        // If cached data is invalid, clear it and continue with API call
        _cacheBox.delete(cacheKey);
      }
    }

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/metrics/recent?start_date=${startDate.toIso8601String()}&end_date=${endDate.toIso8601String()}'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check if the response contains any data
        if (data == null || (data['heartRate'] as List).isEmpty) {
          throw NoDataException(startDate, endDate);
        }
        
        try {
          final metrics = HealthMetrics.fromJson(data);
          // Cache the response
          _cacheBox.put(cacheKey, json.encode(data));
          return metrics;
        } catch (e) {
          throw ApiException('Invalid data format received from server',
              code: 'INVALID_DATA_FORMAT', originalError: e);
        }
      } else if (response.statusCode == 404) {
        throw NoDataException(startDate, endDate);
      } else {
        throw ApiException('Server error: ${response.statusCode}',
            code: 'SERVER_ERROR');
      }
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.',
          code: 'TIMEOUT');
    } on FormatException {
      throw ApiException('Invalid response format from server',
          code: 'INVALID_RESPONSE');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load metrics: $e',
          code: 'UNKNOWN_ERROR', originalError: e);
    }
  }

  Future<HealthMetrics> getRecentMetrics({int days = 7}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    return getMetricsByDateRange(startDate, endDate);
  }

  Future<HealthMetrics> getDailyMetrics(DateTime date) async {
    final cacheKey = 'daily_metrics_${date.toIso8601String()}';
    
    // Check cache first
    final cachedData = _cacheBox.get(cacheKey);
    if (cachedData != null) {
      return HealthMetrics.fromJson(json.decode(cachedData));
    }

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/metrics/daily/${date.toIso8601String()}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Cache the response
        _cacheBox.put(cacheKey, json.encode(data));
        return HealthMetrics.fromJson(data);
      } else {
        throw Exception('Failed to load daily metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load daily metrics: $e');
    }
  }

  Future<List<HealthInsight>> getInsightsByDateRange(DateTime startDate, DateTime endDate) async {
    _validateDateRange(startDate, endDate);
    
    final cacheKey = 'insights_${startDate.toIso8601String()}_${endDate.toIso8601String()}';
    
    // Check cache first
    final cachedData = _cacheBox.get(cacheKey);
    if (cachedData != null) {
      try {
        final List<dynamic> decoded = json.decode(cachedData);
        return decoded.map((item) => HealthInsight.fromJson(item)).toList();
      } catch (e) {
        // If cached data is invalid, clear it and continue with API call
        _cacheBox.delete(cacheKey);
      }
    }

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/insights/recent?start_date=${startDate.toIso8601String()}&end_date=${endDate.toIso8601String()}'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Check if the response contains any data
        if (data.isEmpty) {
          throw NoDataException(startDate, endDate);
        }
        
        try {
          final insights = data.map((item) => HealthInsight.fromJson(item)).toList();
          // Cache the response
          _cacheBox.put(cacheKey, json.encode(data));
          return insights;
        } catch (e) {
          throw ApiException('Invalid data format received from server',
              code: 'INVALID_DATA_FORMAT', originalError: e);
        }
      } else if (response.statusCode == 404) {
        throw NoDataException(startDate, endDate);
      } else {
        throw ApiException('Server error: ${response.statusCode}',
            code: 'SERVER_ERROR');
      }
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.',
          code: 'TIMEOUT');
    } on FormatException {
      throw ApiException('Invalid response format from server',
          code: 'INVALID_RESPONSE');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load insights: $e',
          code: 'UNKNOWN_ERROR', originalError: e);
    }
  }

  Future<List<HealthInsight>> getRecentInsights({int days = 7}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    return getInsightsByDateRange(startDate, endDate);
  }

  Future<List<HealthInsight>> getDailyInsights(DateTime date) async {
    final cacheKey = 'daily_insights_${date.toIso8601String()}';
    
    // Check cache first
    final cachedData = _cacheBox.get(cacheKey);
    if (cachedData != null) {
      final List<dynamic> decoded = json.decode(cachedData);
      return decoded.map((item) => HealthInsight.fromJson(item)).toList();
    }

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/insights/daily/${date.toIso8601String()}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Cache the response
        _cacheBox.put(cacheKey, json.encode(data));
        return data.map((item) => HealthInsight.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load daily insights: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load daily insights: $e');
    }
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
} 