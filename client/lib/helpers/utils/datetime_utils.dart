import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Combines separate date and time strings into a UTC ISO string.
  /// `dateStr` format: 'yyyy-MM-dd'
  /// `timeStr` format: 'HH:mm:ss.SSSSSS'
  static String? combineDateTimeToUtcIso({
    required String? dateStr,
    required String? timeStr,
  }) {
    if (dateStr == null || dateStr.isEmpty || timeStr == null || timeStr.isEmpty) {
      return null;
    }

    try {
      // Parse date
      final selectedDate = DateFormat('yyyy-MM-dd').parse(dateStr);

      // Parse time
      final timeParts = timeStr.split(RegExp(r'[:.]'));
      final seconds = int.parse(timeParts[2]);
      final microseconds = int.parse(timeParts[3].padRight(6, '0')); // ensure 6 digits

      final localDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        seconds,
        (microseconds / 1000).round(), // DateTime takes milliseconds
      );

      return localDateTime.toUtc().toIso8601String();
    } catch (e) {
      return null;
    }
  }

  /// Checks if a UTC ISO datetime string is expired
  static bool isTokenExpired(String? expiresAtUtcIso) {
    if (expiresAtUtcIso == null || expiresAtUtcIso.isEmpty) return false;

    try {
      final expiresAt = DateTime.parse(
          expiresAtUtcIso.endsWith('Z') ? expiresAtUtcIso : "${expiresAtUtcIso}Z"
      );
      final nowUtc = DateTime.now().toUtc();
      return nowUtc.isAfter(expiresAt);
    } catch (e) {
      return false;
    }
  }

  /// Converts a UTC ISO datetime string to local timezone and returns ISO string
  static DateTime? utcIsoToLocalDateTime(String? utcIsoStr) {
    if (utcIsoStr == null || utcIsoStr.isEmpty) return null;

    try {
      final utcDateTime = DateTime.parse(
          utcIsoStr.endsWith('Z') ? utcIsoStr : "${utcIsoStr}Z"
      );
      final localDateTime = utcDateTime.toLocal();

      return localDateTime;
    } catch (e) {
      return null;
    }
  }

  static String? localIsoToUtcIso(String? localDateTimeStr) {
    if (localDateTimeStr == null || localDateTimeStr.isEmpty) return null;

    try {
      final localDateTime = DateTime.parse(localDateTimeStr).toLocal();
      final utcDateTime = localDateTime.toUtc();

      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS');
      return formatter.format(utcDateTime);
    } catch (e) {
      return null;
    }
  }
}
