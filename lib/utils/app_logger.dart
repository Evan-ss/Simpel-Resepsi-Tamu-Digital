import 'package:flutter/foundation.dart';

/// Utility untuk logging interaksi user di terminal.
/// Hanya aktif di debug mode (saat `flutter run`).
class AppLogger {
  static final DateTime _startTime = DateTime.now();

  /// Log: User membuka halaman
  static void pageOpen(String pageName) {
    _log('📄', 'PAGE', pageName);
  }

  /// Log: User menekan tombol
  static void buttonTap(String buttonName, {String? detail}) {
    final msg = detail != null ? '$buttonName ($detail)' : buttonName;
    _log('🔘', 'TAP', msg);
  }

  /// Log: User mengisi form
  static void formInput(String fieldName, {String? value}) {
    final msg = value != null ? '$fieldName = "$value"' : fieldName;
    _log('✏️', 'INPUT', msg);
  }

  /// Log: Aksi database
  static void database(String action, {String? table, String? detail}) {
    final parts = <String>[action];
    if (table != null) parts.add('table=$table');
    if (detail != null) parts.add(detail);
    _log('🗄️', 'DB', parts.join(' | '));
  }

  /// Log: Sukses
  static void success(String message) {
    _log('✅', 'OK', message);
  }

  /// Log: Error / Gagal
  static void error(String message, {dynamic error}) {
    final msg = error != null ? '$message → $error' : message;
    _log('❌', 'ERROR', msg);
  }

  /// Log: Info umum
  static void info(String message) {
    _log('ℹ️', 'INFO', message);
  }

  /// Log: Navigasi
  static void navigation(String from, String to) {
    _log('➡️', 'NAV', '$from → $to');
  }

  /// Internal: cetak ke terminal dengan format rapi
  static void _log(String emoji, String tag, String message) {
    final elapsed = DateTime.now().difference(_startTime);
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    debugPrint('[+$minutes:$seconds] $emoji [$tag] $message');
  }
}
