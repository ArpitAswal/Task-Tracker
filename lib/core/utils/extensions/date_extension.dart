import 'package:intl/intl.dart';

/// ✨ NEW: Extension methods for DateTime to add formatting and utility helpers
extension DateTimeExtensions on DateTime {
  // ============================================================================
  // FORMATTING
  // ============================================================================

  /// Format date as 'dd MMM yyyy' (e.g., '01 Jan 2024')
  String get formatDate {
    return DateFormat('dd MMM yyyy').format(this);
  }

  /// Format date as 'dd/MM/yyyy' (e.g., '01/01/2024')
  String get formatDateSlash {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format date as 'yyyy-MM-dd' (e.g., '2024-01-01')
  String get formatDateISO {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// Format time as 'HH:mm' (e.g., '14:30')
  String get formatTime {
    return DateFormat('HH:mm').format(this);
  }

  /// Format time as 'hh:mm a' (e.g., '02:30 PM')
  String get formatTime12Hour {
    return DateFormat('hh:mm a').format(this);
  }

  /// Format date and time as 'dd MMM yyyy, HH:mm' (e.g., '01 Jan 2024, 14:30')
  String get formatDateTime {
    return DateFormat('dd MMM yyyy, HH:mm').format(this);
  }

  /// Format date and time as 'dd MMM yyyy, hh:mm a' (e.g., '01 Jan 2024, 02:30 PM')
  String get formatDateTime12Hour {
    return DateFormat('dd MMM yyyy, hh:mm a').format(this);
  }

  /// Format as full date (e.g., 'Monday, January 01, 2024')
  String get formatFullDate {
    return DateFormat('EEEE, MMMM dd, yyyy').format(this);
  }

  /// Format as month and year (e.g., 'January 2024')
  String get formatMonthYear {
    return DateFormat('MMMM yyyy').format(this);
  }

  /// Format as day and month (e.g., '01 Jan')
  String get formatDayMonth {
    return DateFormat('dd MMM').format(this);
  }

  /// Custom format
  String format(String pattern) {
    return DateFormat(pattern).format(this);
  }

  // ============================================================================
  // RELATIVE TIME (Time Ago)
  // ============================================================================

  /// Get relative time string (e.g., '2 hours ago', 'Just now')
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Get relative time from now (future dates)
  String get timeFromNow {
    final now = DateTime.now();
    final difference = now.difference(now);

    if (difference.inSeconds < 60) {
      return 'In a few seconds';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'In $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'In $hours ${hours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'In $days ${days == 1 ? 'day' : 'days'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'In $weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'In $months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'In $years ${years == 1 ? 'year' : 'years'}';
    }
  }

  // ============================================================================
  // DATE COMPARISONS
  // ============================================================================

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is in the past
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Check if date is in the future
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  /// Check if date is same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if date is in current week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }

  /// Check if date is in current month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Check if date is in current year
  bool get isThisYear {
    return year == DateTime.now().year;
  }

  // ============================================================================
  // DATE MANIPULATION
  // ============================================================================

  /// Add days to date
  DateTime addDays(int days) {
    return add(Duration(days: days));
  }

  /// Subtract days from date
  DateTime subtractDays(int days) {
    return subtract(Duration(days: days));
  }

  /// Add months to date
  DateTime addMonths(int months) {
    return DateTime(year, month + months, day, hour, minute, second);
  }

  /// Subtract months from date
  DateTime subtractMonths(int months) {
    return DateTime(year, month - months, day, hour, minute, second);
  }

  /// Add years to date
  DateTime addYears(int years) {
    return DateTime(year + years, month, day, hour, minute, second);
  }

  /// Subtract years from date
  DateTime subtractYears(int years) {
    return DateTime(year - years, month, day, hour, minute, second);
  }

  /// Get start of day (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    return add(Duration(days: DateTime.daysPerWeek - weekday)).endOfDay;
  }

  /// Get start of month
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Get end of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59);
  }

  /// Get start of year
  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  /// Get end of year
  DateTime get endOfYear {
    return DateTime(year, 12, 31, 23, 59, 59);
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get age from date of birth
  int get age {
    final now = DateTime.now();
    int age = now.year - year;

    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }

    return age;
  }

  /// Get number of days in month
  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  /// Check if year is leap year
  bool get isLeapYear {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get day of year (1-366)
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }

  /// Copy with new values
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}