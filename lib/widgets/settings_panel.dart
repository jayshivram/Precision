import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsPanel extends ConsumerStatefulWidget {
  const SettingsPanel({super.key});

  @override
  ConsumerState<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends ConsumerState<SettingsPanel> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = 'v${info.version}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'PRECISION',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                color: AppColors.primary,
              ),
            ),
            Text(
              _version,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Display section
            _sectionTitle('DISPLAY'),
            const SizedBox(height: 12),
            _settingRow(
              'Decimal Precision',
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 2, label: Text('2')),
                  ButtonSegment(value: 4, label: Text('4')),
                  ButtonSegment(value: 6, label: Text('6')),
                  ButtonSegment(value: 8, label: Text('8')),
                  ButtonSegment(value: 10, label: Text('10')),
                ],
                selected: {settings.decimalPrecision},
                onSelectionChanged: (v) => notifier.setDecimalPrecision(v.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary.withValues(alpha: 0.2);
                    }
                    return AppColors.surfaceContainerHigh;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return AppColors.onSurfaceVariant;
                  }),
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                showSelectedIcon: false,
              ),
            ),
            _switchRow(
              'Scientific Notation',
              settings.useScientificNotation,
              () => notifier.toggleScientificNotation(),
            ),
            _switchRow(
              'Thousands Separator',
              settings.useThousandsSeparator,
              () => notifier.toggleThousandsSeparator(),
            ),

            const SizedBox(height: 24),
            _sectionTitle('CALCULATOR'),
            const SizedBox(height: 12),
            _settingRow(
              'Angle Mode',
              child: ToggleButtons(
                isSelected: [!settings.isRadianMode, settings.isRadianMode],
                onPressed: (i) => notifier.setRadianMode(i == 1),
                borderRadius: BorderRadius.circular(12),
                selectedColor: AppColors.primary,
                fillColor: AppColors.primary.withValues(alpha: 0.15),
                color: AppColors.onSurfaceVariant,
                constraints: const BoxConstraints(minWidth: 56, minHeight: 36),
                children: const [
                  Text('DEG'),
                  Text('RAD'),
                ],
              ),
            ),
            _switchRow(
              'Haptic Feedback',
              settings.hapticFeedback,
              () => notifier.toggleHapticFeedback(),
            ),

            const SizedBox(height: 24),
            _sectionTitle('CURRENCY'),
            const SizedBox(height: 12),
            _settingRow(
              'Refresh Interval',
              child: DropdownButton<int>(
                value: settings.currencyRefreshMinutes,
                dropdownColor: AppColors.surfaceContainerHigh,
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5 min')),
                  DropdownMenuItem(value: 15, child: Text('15 min')),
                  DropdownMenuItem(value: 30, child: Text('30 min')),
                  DropdownMenuItem(value: 60, child: Text('1 hour')),
                ],
                onChanged: (v) {
                  if (v != null) notifier.setCurrencyRefreshMinutes(v);
                },
              ),
            ),

            const SizedBox(height: 32),
            Text(
              'Rates by api.exchangerate.fun',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 3,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  Widget _settingRow(String label, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _switchRow(String label, bool value, VoidCallback onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) => onChanged(),
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveTrackColor: AppColors.surfaceContainerHigh,
          ),
        ],
      ),
    );
  }
}
