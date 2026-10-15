import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../data/chronova_data_store.dart';
import '../main_navigation_shell.dart';
import 'auth_screen.dart';
import 'config_guide_screen.dart';

/// Root gate that determines whether to show ConfigGuide, AuthScreen, or MainNavigationShell.
class AuthGate extends StatefulWidget {
  final bool forceSampleMode;

  const AuthGate({super.key, this.forceSampleMode = false});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _sampleModeEnabled = false;
  String? _lastLoadedUserId;

  @override
  void initState() {
    super.initState();
    _sampleModeEnabled = widget.forceSampleMode;
    if (_sampleModeEnabled || !SupabaseConfig.isConfigured) {
      ChronovaDataStore.instance.resetToSampleData();
    }
  }

  void _handleSessionChange(Session? session) {
    final userId = session?.user.id;
    if (userId != null) {
      if (_lastLoadedUserId != userId) {
        _lastLoadedUserId = userId;
        ChronovaDataStore.instance.initializeForUser(userId);
      }
    } else {
      if (_lastLoadedUserId != null) {
        _lastLoadedUserId = null;
        ChronovaDataStore.instance.clearUserData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. If user opted into sample mode, show navigation shell with mock data
    if (_sampleModeEnabled) {
      return const MainNavigationShell();
    }

    // 2. If Supabase is not configured via environment variables
    if (!SupabaseConfig.isConfigured) {
      return ConfigGuideScreen(
        onContinueInSampleMode: () {
          setState(() {
            _sampleModeEnabled = true;
          });
        },
      );
    }

    // 3. Supabase is configured: listen to real authentication stream
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (session != null) {
          _handleSessionChange(session);
          return const MainNavigationShell();
        }

        // User is not signed in
        _handleSessionChange(null);
        return AuthScreen(
          onBypassToDemo: () {
            setState(() {
              _sampleModeEnabled = true;
            });
          },
        );
      },
    );
  }
}
