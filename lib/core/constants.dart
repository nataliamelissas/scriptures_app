/// Centralized constants to avoid hardcoded strings throughout the codebase.
library;

/// OpenScriptureAPI configuration.
class ApiConfig {
  static const baseUrl =
      'https://openscriptureapi.org/api/scriptures/v1/lds/en';
  static const timeoutSeconds = 15;
}

/// Local scripture fallback file configuration.
class LocalScriptureConfig {
  // TODO: Make this configurable via settings or environment
  static const basePath =
      r'***REMOVED***';
}

/// Database configuration.
class DbConfig {
  static const fileName = 'scriptures_app';
}
