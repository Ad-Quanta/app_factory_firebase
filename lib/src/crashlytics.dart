import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

const String appFactoryFirebaseGitShaKey = 'git_sha';

abstract class AppCrashReporter {
  void log(String message);

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  });

  Future<void> setUserIdentifier(String? userId);
}

/// Attaches searchable key-value pairs to crash reports.
///
/// This is separate from [AppCrashReporter] so reporters that cannot store
/// custom keys stay valid implementations; callers must check for this type
/// before writing keys.
abstract class AppCrashCustomKeyWriter {
  Future<void> setCustomKey(String key, Object value);
}

class FirebaseAppCrashReporter
    implements AppCrashReporter, AppCrashCustomKeyWriter {
  FirebaseAppCrashReporter({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  void log(String message) {
    _crashlytics.log(message);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  }) {
    return _crashlytics.recordError(error, stackTrace, fatal: fatal);
  }

  @override
  Future<void> setUserIdentifier(String? userId) {
    return _crashlytics.setUserIdentifier(userId ?? '');
  }

  @override
  Future<void> setCustomKey(String key, Object value) {
    return _crashlytics.setCustomKey(key, value);
  }
}

class FirebaseCrashlyticsFlutterErrorInitializer {
  const FirebaseCrashlyticsFlutterErrorInitializer._();

  static void setup(AppCrashReporter crashReporter) {
    FlutterError.onError = (FlutterErrorDetails details) {
      _recordErrorSafely(
        crashReporter,
        details.exception,
        details.stack ?? StackTrace.empty,
      );

      if (!kReleaseMode) {
        FlutterError.presentError(details);
      }
    };

    PlatformDispatcher.instance.onError =
        (Object error, StackTrace stackTrace) {
          _recordErrorSafely(crashReporter, error, stackTrace);
          return kReleaseMode;
        };
  }

  static void _recordErrorSafely(
    AppCrashReporter crashReporter,
    Object error,
    StackTrace stackTrace,
  ) {
    try {
      unawaited(
        crashReporter.recordError(error, stackTrace, fatal: true).catchError((
          Object uploadError,
          StackTrace uploadStackTrace,
        ) {
          _debugRecordFailure(uploadError, uploadStackTrace);
        }),
      );
    } catch (uploadError, uploadStackTrace) {
      _debugRecordFailure(uploadError, uploadStackTrace);
    }
  }

  static void _debugRecordFailure(Object error, StackTrace stackTrace) {
    debugPrint(
      '[AppFactoryFirebase] Crashlytics global error upload failed: '
      '$error\n$stackTrace',
    );
  }
}
