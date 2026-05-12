/// Centralized constants to avoid hardcoded strings throughout the codebase.
library;

import 'package:flutter/foundation.dart';

/// OpenScriptureAPI configuration.
class ApiConfig {
  static const _directUrl =
      'https://openscriptureapi.org/api/scriptures/v1/lds/en';

  // TODO: Replace placeholder with deployed Worker URL, e.g.
  // 'https://scripture-proxy.<your-subdomain>.workers.dev/api/scriptures/v1/lds/en'
  static const _proxyUrl =
      'https://scripture-proxy.talitech.workers.dev/api/scriptures/v1/lds/en';

  /// On web, traffic goes through the Cloudflare Worker to satisfy CORS.
  /// On Android, iOS, and desktop, the API is hit directly.
  static String get baseUrl => kIsWeb ? _proxyUrl : _directUrl;

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
