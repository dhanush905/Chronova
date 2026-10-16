import 'package:flutter/material.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/responsive_container.dart';

/// Screen displayed when Supabase credentials have not been configured yet.
/// Provides copyable setup instructions and allows previewing in local sample mode.
class ConfigGuideScreen extends StatelessWidget {
  final VoidCallback onContinueInSampleMode;

  const ConfigGuideScreen({super.key, required this.onContinueInSampleMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ResponsiveContainer(
              maxWidth: 580,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_sync_outlined,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Supabase Cloud Setup',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Chronova is ready for Phase 2 multi-device synchronization.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Configure Credentials Locally',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'To connect to your Supabase project in the Mumbai region, run Chronova with compile-time environment variables in PowerShell:',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const SelectableText(
                            'flutter run `\n  --dart-define=SUPABASE_URL="https://your-project.supabase.co" `\n  --dart-define=SUPABASE_PUBLISHABLE_KEY="your-anon-key"',
                            style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontFamily: 'monospace',
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Launch Diagnostics:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDiagnosticRow(
                                label: 'SUPABASE_URL Presence:',
                                value: SupabaseConfig.isUrlPresent
                                    ? 'Detected'
                                    : 'Not found',
                                isPositive: SupabaseConfig.isUrlPresent,
                              ),
                              const SizedBox(height: 4),
                              _buildDiagnosticRow(
                                label: 'SUPABASE_URL Validity:',
                                value: SupabaseConfig.isUrlValid
                                    ? 'Valid (host: ${SupabaseConfig.urlHost})'
                                    : (SupabaseConfig.isUrlPresent
                                          ? 'Invalid format (needs https:// & host)'
                                          : 'Missing'),
                                isPositive: SupabaseConfig.isUrlValid,
                              ),
                              const SizedBox(height: 4),
                              _buildDiagnosticRow(
                                label: 'Parsed Scheme & Host:',
                                value: SupabaseConfig.isUrlPresent
                                    ? '${SupabaseConfig.urlScheme}://${SupabaseConfig.urlHost.isNotEmpty ? SupabaseConfig.urlHost : "(no host)"}'
                                    : '(not provided)',
                                isPositive:
                                    SupabaseConfig.hasValidScheme &&
                                    SupabaseConfig.hasHost,
                              ),
                              const SizedBox(height: 4),
                              _buildDiagnosticRow(
                                label: 'Publishable Key Presence:',
                                value: SupabaseConfig.isKeyPresent
                                    ? 'Detected (${SupabaseConfig.keyLength} chars, ${SupabaseConfig.keyType})'
                                    : 'Not found',
                                isPositive: SupabaseConfig.isKeyPresent,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                SupabaseConfig.diagnosticSummary,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Note: Never paste your secret key or database password into chat or commit it to GitHub. Only use the publishable anon key.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onContinueInSampleMode,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Continue in Local Sample Mode'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticRow({
    required String label,
    required String value,
    required bool isPositive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPositive ? AppColors.catEmerald : AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}
