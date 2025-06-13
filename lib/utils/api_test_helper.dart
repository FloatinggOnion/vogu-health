import 'package:vogu_health/services/api_service.dart';
import 'package:vogu_health/models/health_data.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class ApiTestHelper {
  final ApiService apiService;

  ApiTestHelper(this.apiService);

  /// Test the API fixes by running a series of checks
  Future<Map<String, dynamic>> runApiTests() async {
    final results = <String, dynamic>{};
    
    try {
      // Test 1: Check API connectivity
      print('=== Testing API Connectivity ===');
      final isConnected = await apiService.testConnection();
      results['connectivity'] = isConnected;
      print('API Connectivity: $isConnected');

      // Test 2: Clear problematic cache
      print('=== Clearing Problematic Cache ===');
      await apiService.clearProblematicCache();
      results['cache_cleared'] = true;
      print('Cache cleared successfully');

      // Test 3: Test weight data submission (without body composition)
      print('=== Testing Weight Data Submission ===');
      final testWeightData = WeightData(
        timestamp: DateTime.now(),
        value: 70.5,
        bmi: null, // Test null BMI handling
        bodyComposition: null, // Exclude body composition
      );
      
      await apiService.submitWeightData(testWeightData);
      results['weight_submission'] = 'success';
      print('Weight data submitted successfully');

      // Test 4: Test sleep data submission
      print('=== Testing Sleep Data Submission ===');
      final testSleepData = SleepData(
        startTime: DateTime.now().subtract(const Duration(hours: 8)),
        endTime: DateTime.now(),
        quality: 85,
        phases: SleepPhases(
          deep: 120,
          light: 240,
          rem: 90,
          awake: 30,
        ),
      );
      
      await apiService.submitSleepData(testSleepData);
      results['sleep_submission'] = 'success';
      print('Sleep data submitted successfully');

      // Test 5: Test heart rate data submission
      print('=== Testing Heart Rate Data Submission ===');
      final testHeartRateData = HeartRateData(
        timestamp: DateTime.now(),
        value: 72,
        restingRate: 65,
        activityType: 'resting',
      );
      
      await apiService.submitHeartRateData(testHeartRateData);
      results['heart_rate_submission'] = 'success';
      print('Heart rate data submitted successfully');

      // Test 6: Test data retrieval (should handle errors gracefully)
      print('=== Testing Data Retrieval ===');
      try {
        final sleepData = await apiService.getSleepData(days: 1);
        results['sleep_retrieval'] = 'success (${sleepData.length} records)';
        print('Sleep data retrieved: ${sleepData.length} records');
      } catch (e) {
        results['sleep_retrieval'] = 'error: $e';
        print('Sleep data retrieval error: $e');
      }

      try {
        final heartRateData = await apiService.getHeartRateData(days: 1);
        results['heart_rate_retrieval'] = 'success (${heartRateData.length} records)';
        print('Heart rate data retrieved: ${heartRateData.length} records');
      } catch (e) {
        results['heart_rate_retrieval'] = 'error: $e';
        print('Heart rate data retrieval error: $e');
      }

      try {
        final weightData = await apiService.getWeightData(days: 1);
        results['weight_retrieval'] = 'success (${weightData.length} records)';
        print('Weight data retrieved: ${weightData.length} records');
      } catch (e) {
        results['weight_retrieval'] = 'error: $e';
        print('Weight data retrieval error: $e');
      }

      // Test 7: Test insights (should handle backend errors gracefully)
      print('=== Testing Insights ===');
      try {
        final insights = await apiService.getRecentInsights(days: 1);
        results['insights'] = 'success (${insights.length} insights)';
        print('Insights retrieved: ${insights.length} insights');
      } catch (e) {
        results['insights'] = 'error: $e';
        print('Insights error: $e');
      }

      results['overall_status'] = 'completed';
      print('=== All Tests Completed ===');
      
    } catch (e) {
      results['overall_status'] = 'failed';
      results['error'] = e.toString();
      print('Test failed: $e');
    }

    return results;
  }

  /// Get detailed connection information
  Future<Map<String, dynamic>> getDetailedInfo() async {
    final info = await apiService.getConnectionInfo();
    info['timestamp'] = DateTime.now().toIso8601String();
    return info;
  }
} 