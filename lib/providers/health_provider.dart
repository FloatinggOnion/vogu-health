import 'package:flutter/foundation.dart';
import '../models/health_data.dart';
import '../models/feedback.dart';
import '../services/garmin_service.dart';
import '../services/llm_service.dart';
import '../database/database_helper.dart';

class HealthProvider with ChangeNotifier {
  final GarminService _garminService = GarminService();
  final LLMService _llmService = LLMService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  HealthData? _currentHealthData;
  List<HealthData> _healthDataHistory = [];
  List<Feedback> _feedbackHistory = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  HealthData? get currentHealthData => _currentHealthData;
  List<HealthData> get healthDataHistory => _healthDataHistory;
  List<Feedback> get feedbackHistory => _feedbackHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch current health data from Garmin
  Future<void> fetchCurrentHealthData() async {
    _setLoading(true);
    _clearError();
    
    try {
      final healthData = await _garminService.fetchHealthData();
      if (healthData != null) {
        _currentHealthData = healthData;
        
        // Save to database
        await _dbHelper.insertHealthData(healthData.toMap());
        
        // Generate insights
        final feedback = await _llmService.generateHealthInsights(healthData);
        if (feedback != null) {
          await _dbHelper.insertFeedback(feedback.toMap());
          _feedbackHistory.insert(0, feedback);
        }
        
        notifyListeners();
      } else {
        _setError('Failed to fetch health data');
      }
    } catch (e) {
      _setError('Error: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load health data history
  Future<void> loadHealthDataHistory() async {
    _setLoading(true);
    _clearError();
    
    try {
      // For demo, load last 7 days
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      final startDate = '${sevenDaysAgo.year}-${sevenDaysAgo.month.toString().padLeft(2, '0')}-${sevenDaysAgo.day.toString().padLeft(2, '0')}';
      final endDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final data = await _dbHelper.getHealthDataByDateRange(startDate, endDate);
      _healthDataHistory = data.map((map) => HealthData.fromMap(map)).toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Error loading history: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load feedback history
  Future<void> loadFeedbackHistory() async {
    _setLoading(true);
    _clearError();
    
    try {
      final feedback = await _dbHelper.getFeedbackByCategory('health_insights');
      _feedbackHistory = feedback.map((map) => Feedback.fromMap(map)).toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Error loading feedback: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
} 