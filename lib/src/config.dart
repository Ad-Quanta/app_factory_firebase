import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AppFactoryFirebaseConfig {
  const AppFactoryFirebaseConfig({
    required this.options,
    this.enableAnalytics = true,
    this.enableCrashlytics = true,
    this.enablePerformance = true,
    this.captureFlutterErrors = true,
    this.collectionInReleaseOnly = true,
    this.analyticsCollectionEnabled,
    this.crashlyticsCollectionEnabled,
    this.performanceCollectionEnabled,
    this.gitSha = const String.fromEnvironment('APP_GIT_SHA', defaultValue: ''),
    this.defaultEventParameters = const <String, Object?>{},
    this.contextProperties = const <String, String>{},
    this.debugLogInitializeResult = false,
  });

  final FirebaseOptions options;
  final bool enableAnalytics;
  final bool enableCrashlytics;
  final bool enablePerformance;
  final bool captureFlutterErrors;
  final bool collectionInReleaseOnly;
  final bool? analyticsCollectionEnabled;
  final bool? crashlyticsCollectionEnabled;
  final bool? performanceCollectionEnabled;

  /// The source commit used to build the app.
  ///
  /// When omitted, this is read from the `APP_GIT_SHA` Dart define so CI can
  /// inject the value without app-specific runtime code.
  final String gitSha;
  final Map<String, Object?> defaultEventParameters;
  final Map<String, String> contextProperties;
  final bool debugLogInitializeResult;

  bool resolveAnalyticsCollectionEnabled({bool isReleaseMode = kReleaseMode}) {
    return _resolveCollectionEnabled(
      explicitValue: analyticsCollectionEnabled,
      isReleaseMode: isReleaseMode,
    );
  }

  bool resolveCrashlyticsCollectionEnabled({
    bool isReleaseMode = kReleaseMode,
  }) {
    return _resolveCollectionEnabled(
      explicitValue: crashlyticsCollectionEnabled,
      isReleaseMode: isReleaseMode,
    );
  }

  bool resolvePerformanceCollectionEnabled({
    bool isReleaseMode = kReleaseMode,
  }) {
    return _resolveCollectionEnabled(
      explicitValue: performanceCollectionEnabled,
      isReleaseMode: isReleaseMode,
    );
  }

  /// The normalized [gitSha], or `null` when no commit was injected.
  String? get resolvedGitSha {
    final String trimmed = gitSha.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _resolveCollectionEnabled({
    required bool? explicitValue,
    required bool isReleaseMode,
  }) {
    if (explicitValue != null) {
      return explicitValue;
    }
    return collectionInReleaseOnly ? isReleaseMode : true;
  }
}

class AppFactoryFirebaseInitializeResult {
  const AppFactoryFirebaseInitializeResult({
    required this.firebaseInitialized,
    required this.usedExistingFirebaseApp,
    required this.analyticsEnabled,
    required this.crashlyticsEnabled,
    required this.performanceEnabled,
    required this.analyticsCollectionEnabled,
    required this.crashlyticsCollectionEnabled,
    required this.performanceCollectionEnabled,
    required this.flutterErrorsCaptured,
    this.crashlyticsGitShaAttached = false,
    this.initializationErrors = const <String>[],
  });

  final bool firebaseInitialized;
  final bool usedExistingFirebaseApp;
  final bool analyticsEnabled;
  final bool crashlyticsEnabled;
  final bool performanceEnabled;
  final bool analyticsCollectionEnabled;
  final bool crashlyticsCollectionEnabled;
  final bool performanceCollectionEnabled;
  final bool flutterErrorsCaptured;
  final bool crashlyticsGitShaAttached;
  final List<String> initializationErrors;

  @override
  String toString() {
    return 'AppFactoryFirebaseInitializeResult('
        'firebaseInitialized: $firebaseInitialized, '
        'usedExistingFirebaseApp: $usedExistingFirebaseApp, '
        'analyticsEnabled: $analyticsEnabled, '
        'crashlyticsEnabled: $crashlyticsEnabled, '
        'performanceEnabled: $performanceEnabled, '
        'analyticsCollectionEnabled: $analyticsCollectionEnabled, '
        'crashlyticsCollectionEnabled: $crashlyticsCollectionEnabled, '
        'performanceCollectionEnabled: $performanceCollectionEnabled, '
        'flutterErrorsCaptured: $flutterErrorsCaptured, '
        'crashlyticsGitShaAttached: $crashlyticsGitShaAttached, '
        'initializationErrors: $initializationErrors'
        ')';
  }
}
