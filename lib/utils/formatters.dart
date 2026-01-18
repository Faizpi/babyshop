import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormat = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format number to Rupiah (e.g., Rp 12.500)
  static String format(int amount) {
    return _rupiahFormat.format(amount);
  }

  /// Format number to compact Rupiah (e.g., Rp 1,5 jt)
  static String formatCompact(int amount) {
    if (amount >= 1000000) {
      return _compactFormat.format(amount);
    }
    return _rupiahFormat.format(amount);
  }

  /// Format with custom symbol
  static String formatWithSymbol(int amount, String symbol) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: symbol,
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  /// Parse Rupiah string to int
  static int? parse(String text) {
    try {
      // Remove non-numeric characters except for dots
      final cleaned = text.replaceAll(RegExp(r'[^\d]'), '');
      return int.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Format number with thousand separator
  static String formatNumber(int number) {
    final format = NumberFormat('#,###', 'id_ID');
    return format.format(number);
  }
}

class DateFormatter {
  static final DateFormat _fullFormat = DateFormat(
    'EEEE, dd MMMM yyyy',
    'id_ID',
  );
  static final DateFormat _shortFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'id_ID');
  static final DateFormat _dateTimeFormat = DateFormat(
    'dd MMM yyyy, HH:mm',
    'id_ID',
  );

  /// Format to full date (e.g., Senin, 18 Januari 2026)
  static String formatFull(DateTime date) {
    return _fullFormat.format(date);
  }

  /// Format to short date (e.g., 18 Jan 2026)
  static String formatShort(DateTime date) {
    return _shortFormat.format(date);
  }

  /// Format to time only (e.g., 14:30)
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format to date and time (e.g., 18 Jan 2026, 14:30)
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Format to relative time (e.g., 5 menit yang lalu)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} minggu lalu';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} bulan lalu';
    } else {
      return formatShort(date);
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Format smart date (Hari ini, Kemarin, or actual date)
  static String formatSmart(DateTime date) {
    if (isToday(date)) {
      return 'Hari ini, ${formatTime(date)}';
    } else if (isYesterday(date)) {
      return 'Kemarin, ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }
}
