/// Secure compile-time configuration for Supabase in Chronova.
/// Reads SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY (or SUPABASE_ANON_KEY) passed via --dart-define.
/// Never log, print, or expose secret keys or passwords.
class SupabaseConfig {
  // Support uppercase, lowercase, and common synonyms
  static const String _urlUpper = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String _urlLower = String.fromEnvironment(
    'supabase_url',
    defaultValue: '',
  );
  static const String _projUrlUpper = String.fromEnvironment(
    'SUPABASE_PROJECT_URL',
    defaultValue: '',
  );
  static const String _projUrlLower = String.fromEnvironment(
    'supabase_project_url',
    defaultValue: '',
  );

  static const String _pubKeyUpper = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
  static const String _pubKeyLower = String.fromEnvironment(
    'supabase_publishable_key',
    defaultValue: '',
  );
  static const String _anonKeyUpper = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static const String _anonKeyLower = String.fromEnvironment(
    'supabase_anon_key',
    defaultValue: '',
  );
  static const String _keyUpper = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: '',
  );
  static const String _keyLower = String.fromEnvironment(
    'supabase_key',
    defaultValue: '',
  );

  // Runtime test/environment overrides
  static String? _overrideUrl;
  static String? _overridePublishableKey;

  /// Injects test or runtime override values for unit/widget testing.
  static void setOverride({String? url, String? publishableKey}) {
    _overrideUrl = url;
    _overridePublishableKey = publishableKey;
  }

  /// Clears any runtime test overrides.
  static void resetOverride() {
    _overrideUrl = null;
    _overridePublishableKey = null;
  }

  /// Safely sanitizes the Supabase URL:
  /// - Strips outer quotes (single, double, escaped)
  /// - Strips accidental `KEY=` prefix
  /// - Normalizes missing scheme (defaults to https://)
  /// - Strips trailing slashes
  static String _sanitizeUrl(String raw) {
    var val = raw.trim();
    if (val.isEmpty) return '';

    // Strip accidental prefix if a shell passed KEY=VALUE
    final eqIndex = val.indexOf('=');
    if (eqIndex != -1) {
      final prefix = val.substring(0, eqIndex).trim().toUpperCase();
      if (prefix.contains('SUPABASE') || prefix.contains('URL')) {
        val = val.substring(eqIndex + 1).trim();
      }
    }

    // Strip outer quotes and escaped quotes
    val = _stripOuterQuotes(val);

    // If non-empty and no scheme is provided, prepend https:// if it contains a domain dot
    if (val.isNotEmpty &&
        !val.startsWith('http://') &&
        !val.startsWith('https://') &&
        val.contains('.')) {
      val = 'https://$val';
    }

    // Strip trailing slashes
    while (val.endsWith('/')) {
      val = val.substring(0, val.length - 1).trim();
    }

    return val;
  }

  /// Safely sanitizes the publishable key:
  /// - Strips outer quotes
  /// - Strips accidental `KEY=` prefix
  /// - Preserves valid base64 `=` padding
  static String _sanitizeKey(String raw) {
    var val = raw.trim();
    if (val.isEmpty) return '';

    // Strip accidental prefix if a shell passed KEY=VALUE
    final eqIndex = val.indexOf('=');
    if (eqIndex != -1) {
      final prefix = val.substring(0, eqIndex).trim().toUpperCase();
      if (prefix.contains('SUPABASE') || prefix.contains('KEY')) {
        val = val.substring(eqIndex + 1).trim();
      }
    }

    // Strip outer quotes
    val = _stripOuterQuotes(val);

    return val;
  }

  static String _stripOuterQuotes(String raw) {
    var val = raw.trim();
    bool changed = true;
    while (changed && val.isNotEmpty) {
      changed = false;
      val = val.trim();
      if ((val.startsWith('"') && val.endsWith('"')) ||
          (val.startsWith("'") && val.endsWith("'"))) {
        if (val.length >= 2) {
          val = val.substring(1, val.length - 1).trim();
          changed = true;
        }
      }
      if (val.startsWith(r'\"') && val.endsWith(r'\"')) {
        if (val.length >= 4) {
          val = val.substring(2, val.length - 2).trim();
          changed = true;
        }
      }
      if (val.startsWith(r'\"')) {
        val = val.substring(2).trim();
        changed = true;
      }
      if (val.endsWith(r'\"')) {
        val = val.substring(0, val.length - 2).trim();
        changed = true;
      }
      if (val.startsWith('"') || val.startsWith("'") || val.startsWith('\\')) {
        val = val.substring(1).trim();
        changed = true;
      }
      if (val.endsWith('"') || val.endsWith("'") || val.endsWith('\\')) {
        val = val.substring(0, val.length - 1).trim();
        changed = true;
      }
    }
    return val;
  }

  /// Sanitized Supabase project URL.
  static String get supabaseUrl {
    if (_overrideUrl != null) {
      return _sanitizeUrl(_overrideUrl!);
    }

    String raw = '';
    if (_urlUpper.isNotEmpty) {
      raw = _urlUpper;
    } else if (_urlLower.isNotEmpty) {
      raw = _urlLower;
    } else if (_projUrlUpper.isNotEmpty) {
      raw = _projUrlUpper;
    } else if (_projUrlLower.isNotEmpty) {
      raw = _projUrlLower;
    }

    return _sanitizeUrl(raw);
  }

  /// Sanitized Supabase publishable anon key.
  static String get supabasePublishableKey {
    if (_overridePublishableKey != null) {
      return _sanitizeKey(_overridePublishableKey!);
    }

    if (_pubKeyUpper.isNotEmpty) return _sanitizeKey(_pubKeyUpper);
    if (_pubKeyLower.isNotEmpty) return _sanitizeKey(_pubKeyLower);
    if (_anonKeyUpper.isNotEmpty) return _sanitizeKey(_anonKeyUpper);
    if (_anonKeyLower.isNotEmpty) return _sanitizeKey(_anonKeyLower);
    if (_keyUpper.isNotEmpty) return _sanitizeKey(_keyUpper);
    if (_keyLower.isNotEmpty) return _sanitizeKey(_keyLower);
    return '';
  }

  /// Whether a non-empty SUPABASE_URL was provided.
  static bool get isUrlPresent => supabaseUrl.isNotEmpty;

  /// Parsed URI representation of the URL, or null if empty or unparseable.
  static Uri? get parsedUri {
    if (!isUrlPresent) return null;
    try {
      return Uri.tryParse(supabaseUrl);
    } catch (_) {
      return null;
    }
  }

  /// Whether the URI was successfully parsed by Uri.tryParse.
  static bool get isUriParsable => parsedUri != null;

  /// Extracted URL scheme in lowercase (e.g. 'https', 'http', or '').
  static String get urlScheme => parsedUri?.scheme.toLowerCase() ?? '';

  /// Whether the URL scheme is valid ('http' or 'https').
  static bool get hasValidScheme => urlScheme == 'https' || urlScheme == 'http';

  /// Whether a non-empty host was parsed from the URL.
  static bool get hasHost => parsedUri != null && parsedUri!.host.isNotEmpty;

  /// Extracted host domain from URL (e.g. 'atkczrenrlfpssrbdzpi.supabase.co').
  static String get urlHost {
    if (!isUrlPresent) return 'Not configured';
    return hasHost ? parsedUri!.host : 'Invalid URL';
  }

  /// Whether the URL is fully valid (non-empty, parsable, valid scheme, non-empty host).
  static bool get isUrlValid =>
      isUrlPresent && isUriParsable && hasValidScheme && hasHost;

  /// Whether a non-empty publishable key was provided.
  static bool get isKeyPresent => supabasePublishableKey.isNotEmpty;

  /// Safe character length of the publishable key.
  static int get keyLength => supabasePublishableKey.length;

  /// Whether the publishable key meets the minimum length requirement (>= 10 chars).
  static bool get isKeyValid => isKeyPresent && keyLength >= 10;

  /// True when both URL and publishable key are fully valid.
  static bool get isConfigured => isUrlValid && isKeyValid;

  /// Safe key category identifier without revealing key characters.
  static String get keyType {
    if (!isKeyPresent) return 'None';
    final key = supabasePublishableKey;
    if (key.startsWith('sb_publishable_')) {
      return 'Publishable Key';
    } else if (key.startsWith('eyJ')) {
      return 'JWT Anon Token';
    } else {
      return 'API Key';
    }
  }

  /// Safe diagnostic status dictionary without printing any credentials.
  static Map<String, dynamic> get safeDiagnostics => {
    'urlPresent': isUrlPresent,
    'uriParsable': isUriParsable,
    'urlScheme': urlScheme.isNotEmpty ? urlScheme : '(none)',
    'hasValidScheme': hasValidScheme,
    'hasHost': hasHost,
    'hostDomain': urlHost.isNotEmpty ? urlHost : '(empty)',
    'keyPresent': isKeyPresent,
    'keyLength': keyLength,
    'keyType': keyType,
    'isConfigured': isConfigured,
  };

  /// Safe diagnostics summary (does not expose keys or sensitive credentials).
  static String get diagnosticSummary {
    if (isConfigured) {
      return 'Supabase configured: Connected to host "$urlHost" ($keyType, $keyLength chars).';
    }

    final missing = <String>[];
    if (!isUrlPresent) {
      missing.add('SUPABASE_URL (not found)');
    } else if (!isUriParsable || !hasHost || !hasValidScheme) {
      missing.add(
        'SUPABASE_URL (invalid: scheme=$urlScheme, host=$urlHost; must be https://<host>)',
      );
    }

    if (!isKeyPresent) {
      missing.add('SUPABASE_PUBLISHABLE_KEY (not found)');
    } else if (!isKeyValid) {
      missing.add(
        'SUPABASE_PUBLISHABLE_KEY (too short: $keyLength chars, needs >= 10)',
      );
    }

    return 'Configuration Missing: ${missing.join(', ')}. Pass via --dart-define at launch.';
  }

  /// Human-readable status for badge displays.
  static String get statusDescription =>
      isConfigured ? 'Supabase Configured' : 'Missing credentials';
}
