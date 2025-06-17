import 'package:vogu_health/models/api_models.dart';
import 'package:vogu_health/services/health_api_service.dart';

class ApiUsageExample {
  final HealthApiService _apiService = HealthApiService();

  // Example: Submit sleep data
  Future<void> submitSleepData() async {
    try {
      final request = SleepDataRequest(
        startTime: DateTime.now().subtract(const Duration(hours: 8)).toUtc().toIso8601String(),
        endTime: DateTime.now().toUtc().toIso8601String(),
        quality: 85,
        phases: SleepPhases(
          deep: 120,
          light: 240,
          rem: 90,
          awake: 30,
        ),
        source: 'mobile_app',
      );

      final response = await _apiService.submitSleepData(request);
      print('Sleep data submitted: ${response.message}');
    } catch (e) {
      print('Error submitting sleep data: $e');
    }
  }

  // Example: Submit heart rate data
  Future<void> submitHeartRateData() async {
    try {
      final request = HeartRateDataRequest(
        timestamp: DateTime.now().toUtc().toIso8601String(),
        value: 75,
        restingRate: 60,
        activityType: 'walking',
        source: 'mobile_app',
      );

      final response = await _apiService.submitHeartRateData(request);
      print('Heart rate data submitted: ${response.message}');
    } catch (e) {
      print('Error submitting heart rate data: $e');
    }
  }

  // Example: Submit weight data
  Future<void> submitWeightData() async {
    try {
      final request = WeightDataRequest(
        timestamp: DateTime.now().toUtc().toIso8601String(),
        value: 70.5,
        bmi: 22.5,
        bodyComposition: BodyComposition(
          bodyFat: 18.5,
          muscleMass: 40.2,
          waterPercentage: 55.0,
          boneMass: 3.2,
        ),
        source: 'mobile_app',
      );

      final response = await _apiService.submitWeightData(request);
      print('Weight data submitted: ${response.message}');
    } catch (e) {
      print('Error submitting weight data: $e');
    }
  }

  // Example: Get health data
  Future<void> getHealthData() async {
    try {
      // Get sleep data
      final sleepData = await _apiService.getSleepData(days: 7);
      print('Sleep data: ${sleepData.length} records');

      // Get heart rate data
      final heartRateData = await _apiService.getHeartRateData(days: 7);
      print('Heart rate data: ${heartRateData.length} records');

      // Get weight data
      final weightData = await _apiService.getWeightData(days: 7);
      print('Weight data: ${weightData.length} records');
    } catch (e) {
      print('Error getting health data: $e');
    }
  }

  // Example: Get daily summary
  Future<void> getDailySummary() async {
    try {
      final summary = await _apiService.getDailyHealthSummary(DateTime.now());
      print('Daily summary for ${summary.date}:');
      print('- Sleep records: ${summary.sleep.length}');
      print('- Heart rate records: ${summary.heartRate.length}');
      print('- Weight records: ${summary.weight.length}');
    } catch (e) {
      print('Error getting daily summary: $e');
    }
  }

  // Example: Get insights
  Future<void> getInsights() async {
    try {
      // Get recent insights
      final recentInsights = await _apiService.getRecentInsights(days: 7);
      print('Recent insights:');
      print('- Summary: ${recentInsights.summary}');
      print('- Status: ${recentInsights.status}');
      print('- Highlights: ${recentInsights.highlights.join(', ')}');

      // Get daily insights
      final dailyInsights = await _apiService.getDailyInsights(DateTime.now());
      print('\nDaily insights:');
      print('- Summary: ${dailyInsights.summary}');
      print('- Status: ${dailyInsights.status}');
      print('- Recommendations: ${dailyInsights.recommendations.join(', ')}');
    } catch (e) {
      print('Error getting insights: $e');
    }
  }

  // Example: Test connection
  Future<void> testConnection() async {
    try {
      final isConnected = await _apiService.testConnection();
      print('API connection test: ${isConnected ? 'Success' : 'Failed'}');
    } catch (e) {
      print('Error testing connection: $e');
    }
  }

  // Clean up resources
  void dispose() {
    _apiService.dispose();
  }
} 