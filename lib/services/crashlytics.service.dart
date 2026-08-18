import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Central place to record errors, warnings and logs to Firebase Crashlytics.
///
/// Usage:
/// ```dart
/// CrashlyticsService.log("Loading orders");
/// CrashlyticsService.recordWarning("Order total mismatch", reason: "checkout");
/// CrashlyticsService.recordError(error, stackTrace, reason: "loadAppSettings");
/// ```
class CrashlyticsService {
  CrashlyticsService._();

  static FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  /// Breadcrumb log, shown in the crash/error timeline on Crashlytics.
  static void log(String message) {
    if (kDebugMode) {
      print("Crashlytics log ==> $message");
    }
    _crashlytics.log(message);
  }

  /// Records a non-fatal error.
  static Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      print("Crashlytics error ==> $error${reason != null ? ' ($reason)' : ''}");
    }
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      information: information,
      fatal: fatal,
    );
  }

  /// Records a warning as a non-fatal error, prefixed so it's easy to filter
  /// from real errors in the Crashlytics dashboard.
  static Future<void> recordWarning(
    String message, {
    String? reason,
    StackTrace? stackTrace,
  }) async {
    if (kDebugMode) {
      print("Crashlytics warning ==> $message${reason != null ? ' ($reason)' : ''}");
    }
    await _crashlytics.recordError(
      "Warning: $message",
      stackTrace ?? StackTrace.current,
      reason: reason,
      fatal: false,
    );
  }

  /// Identifies the current user in Crashlytics reports.
  static Future<void> setUserId(String userId) {
    return _crashlytics.setUserIdentifier(userId);
  }

  /// Attaches a custom key/value to subsequent Crashlytics reports.
  static Future<void> setCustomKey(String key, Object value) {
    return _crashlytics.setCustomKey(key, value);
  }
}
