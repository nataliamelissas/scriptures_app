/// Centralized constants to avoid hardcoded strings throughout the codebase.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  static const envKey = 'SCRIPTURE_BASE_PATH';

  /// Reads the base path from the `.env` file at runtime.
  /// Returns an empty string if the key is absent (graceful degradation).
  static String get basePath => dotenv.env[envKey] ?? '';
}

/// Database configuration.
class DbConfig {
  static const fileName = 'scriptures_app';
}

/// User-defined tag rules.
class TagConfig {
  /// Maximum characters per tag (enforced at input).
  static const maxLength = 15;
}
