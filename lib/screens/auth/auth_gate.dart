import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_colors.dart';
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

    debugPrint(
      '[AuthGate] initState: sampleMode=$_sampleModeEnabled, isConfigured=${SupabaseConfig.isConfigured}, urlValid=${SupabaseConfig.isUrlValid}, keyValid=${SupabaseConfig.isKeyValid}',
    );

    if (_sampleModeEnabled || !SupabaseConfig.isConfigured) {
      ChronovaDataStore.instance.enableLocalSampleMode();
    } else {
      // Initialize repository only when configuration is valid
      ChronovaDataStore.instance.setupDefaultRepository();
      try {
        final existingSession = Supabase.instance.client.auth.currentSession;
        if (existingSession != null) {
          _lastLoadedUserId = existingSession.user.id;
          ChronovaDataStore.instance.initializeForUser(existingSession.user.id);
        }
      } catch (_) {}
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
    debugPrint(
      '[AuthGate] build: sampleMode=$_sampleModeEnabled, isConfigured=${SupabaseConfig.isConfigured}, hasInitError=${ChronovaDataStore.instance.initializationError != null}',
    );

    // 1. If user explicitly opted into sample mode, show navigation shell with mock data
    if (_sampleModeEnabled) {
      return const MainNavigationShell();
    }

    // 2. If Supabase is not configured via environment variables
    if (!SupabaseConfig.isConfigured) {
      return ConfigGuideScreen(
        onContinueInSampleMode: () {
          setState(() {
            _sampleModeEnabled = true;
            ChronovaDataStore.instance.enableLocalSampleMode();
          });
        },
      );
    }

    // 3. If Supabase initialization failed, show clear error rather than crashing or silent fallback
    if (ChronovaDataStore.instance.initializationError != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Supabase Connection Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ChronovaDataStore.instance.initializationError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _sampleModeEnabled = true;
                      ChronovaDataStore.instance.enableLocalSampleMode();
                    });
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Continue in Local Sample Mode (Fallback)'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 4. Supabase is configured: listen to real authentication stream
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (session != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleSessionChange(session);
          });
          return const MainNavigationShell();
        }

        // User is not signed in
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleSessionChange(null);
        });
        return AuthScreen(
          onBypassToDemo: () {
            setState(() {
              _sampleModeEnabled = true;
              ChronovaDataStore.instance.enableLocalSampleMode();
            });
          },
        );
      },
    );
  }
}
