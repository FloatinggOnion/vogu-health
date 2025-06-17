import 'package:intl/intl.dart';

class ValidationUtils {
  static bool isValidIso8601Date(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }

  static String? validateIso8601Date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    if (!isValidIso8601Date(value)) {
      return 'Invalid date format. Use ISO 8601 (e.g., 2024-03-20T22:00:00Z)';
    }
    return null;
  }

  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? validateNumericRange(String? value, num min, num max) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final number = num.tryParse(value);
    if (number == null) {
      return 'Must be a number';
    }
    if (!isInRange(number, min, max)) {
      return 'Must be between $min and $max';
    }
    return null;
  }

  static String? validateOptionalNumericRange(String? value, num min, num max) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final number = num.tryParse(value);
    if (number == null) {
      return 'Must be a number';
    }
    if (!isInRange(number, min, max)) {
      return 'Must be between $min and $max';
    }
    return null;
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(dateTime.toUtc());
  }
} 