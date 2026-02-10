import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late Logger _logger;
bool _enableLogging = false;

/// Initialize logger based on .env flag
void initLogger() {
  _enableLogging = dotenv.env['ENABLE_APP_LOGGER']?.toLowerCase() == 'true';

  if (_enableLogging) {
    _logger = Logger(
      printer: PrettyPrinter(
        lineLength: 180,
        methodCount: 0,
        errorMethodCount: 10,
      ),
    );
  } else {
    // No-op logger
    _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  }
}

/// Verbose logging
void logV(dynamic message) {
  if (_enableLogging) _logger.t(message);
}

/// Debug logging
void logD(dynamic message) {
  if (_enableLogging) _logger.d(message);
}

/// Info logging
void logI(dynamic message) {
  if (_enableLogging) _logger.i(message);
}

/// Warn logging
void logW(dynamic message) {
  if (_enableLogging) _logger.w(message);
}

/// Error logging
void logE(dynamic message) {
  if (_enableLogging) _logger.e(message);
}

/// What The F**k logging
void logWTF(dynamic message) {
  if (_enableLogging) _logger.f(message);
}
