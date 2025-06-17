import 'package:flutter/foundation.dart';
import 'package:vogu_health/core/interfaces/state_manager.dart';
import 'package:vogu_health/core/interfaces/repository.dart';
import 'package:vogu_health/core/exceptions/api_exceptions.dart';
import 'package:vogu_health/models/api_models.dart';

/// Concrete implementation of DailySummaryStateManager
class DailySummaryStateManagerImpl extends ChangeNotifier implements DailySummaryStateManager {
  final DailySummaryRepository _repository;
  
  HealthDataState _state = const LoadingState();
  bool _isConnected = false;
  DailyHealthData? _dailySummary;

  DailySummaryStateManagerImpl(this._repository);

  @override
  HealthDataState get state => _state;

  @override
  bool get isLoading => _state is LoadingState;

  @override
  String? get error {
    if (_state is ErrorState) {
      return (_state as ErrorState).message;
    }
    return null;
  }

  @override
  bool get isConnected => _isConnected;

  @override
  DailyHealthData? get dailySummary => _dailySummary;

  @override
  Future<void> initialize() async {
    _setState(const LoadingState());
    try {
      await loadDailySummary(DateTime.now());
      _isConnected = true;
    } catch (e) {
      _setState(ErrorState(e.toString()));
      _isConnected = false;
    }
  }

  @override
  Future<void> refresh() async {
    await loadDailySummary(DateTime.now());
  }

  @override
  void clearError() {
    if (_state is ErrorState) {
      _setState(const EmptyState());
    }
  }

  @override
  Future<void> loadDailySummary(DateTime date) async {
    _setState(const LoadingState());
    try {
      _dailySummary = await _repository.getSummary(date);
      _setState(SuccessState(_dailySummary));
    } catch (e) {
      _setState(ErrorState(e.toString()));
    }
  }

  void _setState(HealthDataState newState) {
    _state = newState;
    notifyListeners();
  }
} 