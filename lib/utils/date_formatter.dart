import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');
  
  /// Converts a DateTime to a display string (e.g., "15 Jan 2023")
  static String toDisplayDate(DateTime date) {
    return _displayFormat.format(date);
  }
  
  /// Parses a display date string to a DateTime
  static DateTime parseDisplayDate(String displayDate) {
    try {
      return _displayFormat.parse(displayDate);
    } catch (e) {
      return DateTime.now();
    }
  }
  
  /// Converts a DateTime to an API-friendly string (e.g., "2023-01-15")
  static String toApiDate(DateTime date) {
    return _apiFormat.format(date);
  }
  
  /// Parses an API date string to a DateTime
  static DateTime parseApiDate(String apiDate) {
    try {
      return _apiFormat.parse(apiDate);
    } catch (e) {
      return DateTime.now();
    }
  }
  
  /// Returns a relative time description (e.g., "2 days ago", "Just now")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
