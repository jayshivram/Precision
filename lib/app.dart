import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_state_provider.dart';
import 'providers/update_provider.dart';
import 'screens/basic_calculator_screen.dart';
import 'screens/scientific_calculator_screen.dart';
import 'screens/unit_converter_screen.dart';
import 'screens/currency_converter_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'widgets/history_panel.dart';
import 'widgets/settings_panel.dart';

class PrecisionApp extends ConsumerWidget {
  const PrecisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Precision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _SplashGate(),
    );
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onComplete: () => setState(() => _showSplash = false),
      );
    }
    return const _AppShell();
  }
}

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _updateBannerDismissed = false;

  static const _tabs = ['BASIC', 'SCIENTIFIC', 'CONVERTER', 'CURRENCY'];
  static const _tabIcons = [
    Icons.calculate_outlined,
    Icons.functions,
    Icons.swap_horiz,
    Icons.monetization_on_outlined,
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surfaceContainerLowest,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Check for updates and fire system notification if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final container = ProviderScope.containerOf(context);
      final info = await container.read(updateProvider.future);
      if (info != null && info.hasUpdate && mounted) {
        final granted = await NotificationService.requestPermission();
        if (granted) {
          await NotificationService.showUpdateNotification(info.latestVersion);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(activeTabProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceContainerLow,
            title: Text('Exit Precision?',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            content: Text('Are you sure you want to close the app?',
              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('CANCEL',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600, letterSpacing: 1.5)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('EXIT',
                  style: GoogleFonts.inter(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600, letterSpacing: 1.5)),
              ),
            ],
          ),
        );
        if (shouldExit == true && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawer: const SettingsPanel(),
        endDrawer: const HistoryPanel(),
        endDrawerEnableOpenDragGesture: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: AppColors.surface,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.primary),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PRECISION',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  // Desktop tab bar (hidden on small screens)
                  if (MediaQuery.of(context).size.width >= 600)
                    ...List.generate(_tabs.length, (i) {
                      final isActive = activeTab == i;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => ref.read(activeTabProvider.notifier).state = i,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _tabs[i],
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  IconButton(
                    icon: const Icon(Icons.history, color: AppColors.onSurfaceVariant),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Update banner
          Consumer(builder: (context, ref, _) {
            if (_updateBannerDismissed) return const SizedBox.shrink();
            final updateAsync = ref.watch(updateProvider);
            return updateAsync.maybeWhen(
              data: (info) {
                if (info == null || !info.hasUpdate) return const SizedBox.shrink();
                return _UpdateBanner(
                  version: info.latestVersion,
                  onDismiss: () {
                    setState(() => _updateBannerDismissed = true);
                    NotificationService.cancelUpdateNotification();
                  },
                );
              },
              orElse: () => const SizedBox.shrink(),
            );
          }),
          Expanded(
            child: IndexedStack(
              index: activeTab,
              children: const [
                BasicCalculatorScreen(),
                ScientificCalculatorScreen(),
                UnitConverterScreen(),
                CurrencyConverterScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_tabs.length, (i) {
                      final isActive = activeTab == i;
                      return GestureDetector(
                        onTap: () => ref.read(activeTabProvider.notifier).state = i,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary.withValues(alpha: 0.10)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _tabIcons[i],
                                size: 22,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _tabs[i],
                                style: GoogleFonts.manrope(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            )
          : null,
      ),
    );
  }
}

class _UpdateBanner extends StatelessWidget {
  final String version;
  final VoidCallback onDismiss;

  const _UpdateBanner({required this.version, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.system_update_outlined,
              color: AppColors.onPrimary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precision v$version is available!',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
                Text(
                  'Visit GitHub to download the update.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.onPrimary, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
