import 'package:flutter/foundation.dart';

class Logger {
  static final List<String> _logs = [];
  static const int _maxLogs = 100;

  static void i(String message) => _addLog('INFO', message);
  static void w(String message) => _addLog('WARN', message);
  static void e(String message, [dynamic error, StackTrace? stack]) {
    final fullMessage = error != null ? '$message | Error: $error' : message;
    _addLog('ERROR', fullMessage);
    if (kDebugMode && stack != null) {
      debugPrint(stack.toString());
    }
  }

  static void _addLog(String level, String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final logLine = '[$timestamp] $level: $message';

    _logs.insert(0, logLine);
    if (_logs.length > _maxLogs) {
      _logs.removeLast();
    }

    if (kDebugMode) {
      debugPrint('🚀 $logLine');
    }
  }

  static List<String> get logs => List.unmodifiable(_logs);
  static void clear() => _logs.clear();
}
