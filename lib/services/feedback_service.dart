import 'storage_service.dart';

class FeedbackService {
  final StorageService _storage;
  List<String> _feedbackHistory = [];

  FeedbackService(this._storage);

  Future<void> insertFeedback(String category, String content) async {
    await _storage.insertFeedback(category, content);
    _feedbackHistory.add(content);
  }

  Future<List<String>> getFeedbackByCategory(String category) async {
    return await _storage.getFeedbackByCategory(category);
  }

  Future<void> loadFeedbackHistory() async {
    _feedbackHistory = await getFeedbackByCategory('general');
  }

  List<String> get feedbackHistory => _feedbackHistory;
} 