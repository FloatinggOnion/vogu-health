import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vogu_health/models/api_models.dart';
import 'package:vogu_health/models/insight_models.dart';
import 'package:vogu_health/core/exceptions/api_exceptions.dart';
import 'package:vogu_health/core/config/app_config.dart';

class HealthApiService {
  final String baseUrl;
  final http.Client _client;

  HealthApiService({
    this.baseUrl = 'https://vogu-health-be.onrender.com',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<T> _makeRequest<T>({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final uri = Uri.parse('$baseUrl/$cleanEndpoint');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      print('Making $method request to $uri');
      if (body != null) {
        print('Request body: ${jsonEncode(body)}');
      }

      final response = await _client.send(
        http.Request(method, uri)
          ..headers.addAll(headers)
          ..body = body != null ? jsonEncode(body) : '',
      );

      final responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      final json = jsonDecode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (fromJson != null) {
          return fromJson(json);
        }
        return json as T;
      }

      throw ApiException(
        json['message'] ?? 'Unknown error occurred',
        statusCode: response.statusCode,
        data: json,
      );
    } catch (e) {
      print('Request failed: $e');
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to make request: $e');
    }
  }

  Future<ApiResponse> submitSleepData(SleepDataRequest request) async {
    if (request.quality < 0 || request.quality > 100) {
      throw ValidationException(
        'Invalid sleep quality',
        errors: {'quality': 'Must be between 0 and 100'},
      );
    }

    return _makeRequest<ApiResponse>(
      endpoint: '/api/v1/health-data/sleep',
      method: 'POST',
      body: request.toJson(),
      fromJson: (json) => ApiResponse.fromJson(json),
    );
  }

  Future<List<SleepDataResponse>> getSleepData({int days = 7}) async {
    if (days < 1 || days > 30) {
      throw ValidationException(
        'Invalid days parameter',
        errors: {'days': 'Must be between 1 and 30'},
      );
    }

    return _makeRequest<List<SleepDataResponse>>(
      endpoint: '/api/v1/health-data/sleep?days=$days',
      method: 'GET',
      fromJson: (json) {
        if (json is! Map<String, dynamic>) {
          throw ApiException('Invalid response format', statusCode: 422);
        }
        
        final data = json['data'];
        if (data == null) {
          return []; // Return empty list if no data
        }
        
        if (data is! List) {
          throw ApiException('Data field is not a list', statusCode: 422);
        }
        
        return data
            .map((item) => SleepDataResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse> submitHeartRateData(HeartRateDataRequest request) async {
    if (request.value < 40 || request.value > 200) {
      throw ValidationException(
        'Invalid heart rate',
        errors: {'value': 'Must be between 40 and 200'},
      );
    }

    return _makeRequest<ApiResponse>(
      endpoint: '/api/v1/health-data/heart-rate',
      method: 'POST',
      body: request.toJson(),
      fromJson: (json) => ApiResponse.fromJson(json),
    );
  }

  Future<List<HeartRateDataResponse>> getHeartRateData({int days = 7}) async {
    if (days < 1 || days > 30) {
      throw ValidationException(
        'Invalid days parameter',
        errors: {'days': 'Must be between 1 and 30'},
      );
    }

    return _makeRequest<List<HeartRateDataResponse>>(
      endpoint: '/api/v1/health-data/heart_rate?days=$days',
      method: 'GET',
      fromJson: (json) {
        if (json is! Map<String, dynamic>) {
          throw ApiException('Invalid response format', statusCode: 422);
        }
        
        final data = json['data'];
        if (data == null) {
          return []; // Return empty list if no data
        }
        
        if (data is! List) {
          throw ApiException('Data field is not a list', statusCode: 422);
        }
        
        return data
            .map((item) => HeartRateDataResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse> submitWeightData(WeightDataRequest request) async {
    if (request.value < 20 || request.value > 300) {
      throw ValidationException(
        'Invalid weight',
        errors: {'value': 'Must be between 20 and 300 kg'},
      );
    }

    return _makeRequest<ApiResponse>(
      endpoint: '/api/v1/health-data/weight',
      method: 'POST',
      body: request.toJson(),
      fromJson: (json) => ApiResponse.fromJson(json),
    );
  }

  Future<List<WeightDataResponse>> getWeightData({int days = 7}) async {
    if (days < 1 || days > 30) {
      throw ValidationException(
        'Invalid days parameter',
        errors: {'days': 'Must be between 1 and 30'},
      );
    }

    return _makeRequest<List<WeightDataResponse>>(
      endpoint: '/api/v1/health-data/weight?days=$days',
      method: 'GET',
      fromJson: (json) {
        if (json is! Map<String, dynamic>) {
          throw ApiException('Invalid response format', statusCode: 422);
        }
        
        final data = json['data'];
        if (data == null) {
          return []; // Return empty list if no data
        }
        
        if (data is! List) {
          throw ApiException('Data field is not a list', statusCode: 422);
        }
        
        return data
            .map((item) => WeightDataResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<DailyHealthSummaryResponse> getDailyHealthSummary(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    return _makeRequest<DailyHealthSummaryResponse>(
      endpoint: '/api/v1/health-data/daily/$dateStr',
      method: 'GET',
      fromJson: (json) => DailyHealthSummaryResponse.fromJson(json),
    );
  }

  Future<InsightResponse> getRecentInsights({int days = 7}) async {
    if (days < 1 || days > 30) {
      throw ValidationException(
        'Invalid days parameter',
        errors: {'days': 'Must be between 1 and 30'},
      );
    }

    return _makeRequest<InsightResponse>(
      endpoint: '/api/v1/insights/recent?days=$days',
      method: 'GET',
      fromJson: (json) {
        if (json is! Map<String, dynamic>) {
          throw ApiException('Invalid response format', statusCode: 422);
        }
        
        if (json['status'] != 'success') {
          throw ApiException('API request failed', statusCode: 422);
        }
        
        final insights = json['insights'];
        if (insights == null || insights is! Map<String, dynamic>) {
          throw ApiException('No insights data found', statusCode: 422);
        }
        
        return InsightResponse.fromJson(insights);
      },
    );
  }

  Future<InsightResponse> getDailyInsights(String date) async {
    return _makeRequest<InsightResponse>(
      endpoint: '/api/v1/insights/daily/$date',
      method: 'GET',
      fromJson: (json) {
        if (json is! Map<String, dynamic>) {
          throw ApiException('Invalid response format', statusCode: 422);
        }
        
        if (json['status'] != 'success') {
          throw ApiException('API request failed', statusCode: 422);
        }
        
        final insights = json['insights'];
        if (insights == null || insights is! Map<String, dynamic>) {
          throw ApiException('No insights data found', statusCode: 422);
        }
        
        return InsightResponse.fromJson(insights);
      },
    );
  }

  Future<bool> testConnection() async {
    try {
      await _makeRequest(
        endpoint: '/api/v1/health',
        method: 'GET',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<SleepInsightResponse>> getSleepInsights() async {
    return _makeRequest<List<SleepInsightResponse>>(
      endpoint: '/api/v1/insights/sleep',
      method: 'GET',
      fromJson: (json) {
        if (json is! Map<String, dynamic>) {
          throw ApiException('Invalid response format', statusCode: 422);
        }
        
        final insights = json['insights'];
        if (insights == null) {
          return []; // Return empty list if no insights
        }
        
        if (insights is! List) {
          throw ApiException('Insights field is not a list', statusCode: 422);
        }
        
        return insights
            .map((item) => SleepInsightResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<HeartRateInsightResponse>> getHeartRateInsights() async {
    return _makeRequest<List<HeartRateInsightResponse>>(
      endpoint: '/api/v1/insights/heart-rate',
      method: 'GET',
      fromJson: (json) {
        if (json is! Map<String, dynamic>) {
          throw ApiException('Invalid response format', statusCode: 422);
        }
        
        final insights = json['insights'];
        if (insights == null) {
          return []; // Return empty list if no insights
        }
        
        if (insights is! List) {
          throw ApiException('Insights field is not a list', statusCode: 422);
        }
        
        return insights
            .map((item) => HeartRateInsightResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<WeightInsightResponse>> getWeightInsights() async {
    return _makeRequest<List<WeightInsightResponse>>(
      endpoint: '/api/v1/insights/weight',
      method: 'GET',
      fromJson: (json) {
        if (json is! Map<String, dynamic>) {
          throw ApiException('Invalid response format', statusCode: 422);
        }
        
        final insights = json['insights'];
        if (insights == null) {
          return []; // Return empty list if no insights
        }
        
        if (insights is! List) {
          throw ApiException('Insights field is not a list', statusCode: 422);
        }
        
        return insights
            .map((item) => WeightInsightResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<CorrelationInsightResponse>> getCorrelationInsights() async {
    return _makeRequest<List<CorrelationInsightResponse>>(
      endpoint: '/api/v1/insights/correlations',
      method: 'GET',
      fromJson: (json) {
        if (json is! Map<String, dynamic>) {
          throw ApiException('Invalid response format', statusCode: 422);
        }
        
        final insights = json['insights'];
        if (insights == null) {
          return []; // Return empty list if no insights
        }
        
        if (insights is! List) {
          throw ApiException('Insights field is not a list', statusCode: 422);
        }
        
        return insights
            .map((item) => CorrelationInsightResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  void dispose() {
    _client.close();
  }
} 