import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'data/chronova_data_store.dart';
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabasePublishableKey,
      );
      ChronovaDataStore.instance.setupDefaultRepository();
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
    }
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
