import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'data/chronova_data_store.dart';
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint(
    '[Chronova] Startup diagnostics: urlPresent=${SupabaseConfig.isUrlPresent}, urlValid=${SupabaseConfig.isUrlValid}, scheme=${SupabaseConfig.urlScheme}, host=${SupabaseConfig.urlHost}, keyPresent=${SupabaseConfig.isKeyPresent}, keyValid=${SupabaseConfig.isKeyValid}, isConfigured=${SupabaseConfig.isConfigured}',
  );

  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabasePublishableKey,
      );
      // Initialize Supabase repository only when configuration is valid
      ChronovaDataStore.instance.setupDefaultRepository();
      debugPrint(
        '[Chronova] Supabase initialized successfully for host: ${SupabaseConfig.urlHost}',
      );
    } catch (e) {
      final errorMsg = 'Failed to initialize Supabase: $e';
      debugPrint('[Chronova] $errorMsg');
      ChronovaDataStore.instance.recordInitializationError(errorMsg);
    }
  } else {
    debugPrint(
      '[Chronova] Supabase is not configured. ${SupabaseConfig.diagnosticSummary}',
    );
    ChronovaDataStore.instance.enableLocalSampleMode();
  }

  runApp(const ChronovaApp());
}

/// Root widget for Chronova.
class ChronovaApp extends StatelessWidget {
  final Widget? homeOverride;

  const ChronovaApp({super.key, this.homeOverride});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chronova',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: homeOverride ?? const AuthGate(),
    );
  }
}
