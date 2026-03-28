import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/calc_button.dart';

class ScientificCalculatorScreen extends ConsumerWidget {
  const ScientificCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final settings = ref.watch(settingsProvider);

    return SafeArea(
      child: Column(
        children: [
          // Display area (compact)
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Angle mode badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          settings.isRadianMode ? 'RAD' : 'DEG',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 32,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        state.hasResult
                            ? state.expression
                            : (state.previewResult != null
                                ? '= ${state.previewResult}'
                                : ' '),
                        style: GoogleFonts.manrope(
                          fontSize: 22,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 64,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        state.error ?? state.display,
                        style: GoogleFonts.manrope(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: state.error != null ? AppColors.error : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable scientific function strips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                // Row 1: Trig functions
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    children: [
                      _sciChip('sin', () => notifier.inputFunction('sin'), settings.hapticFeedback),
                      _sciChip('cos', () => notifier.inputFunction('cos'), settings.hapticFeedback),
                      _sciChip('tan', () => notifier.inputFunction('tan'), settings.hapticFeedback),
                      _sciChip('sin⁻¹', () => notifier.inputFunction('asin'), settings.hapticFeedback),
                      _sciChip('cos⁻¹', () => notifier.inputFunction('acos'), settings.hapticFeedback),
                      _sciChip('tan⁻¹', () => notifier.inputFunction('atan'), settings.hapticFeedback),
                      _sciChip('|x|', () => notifier.inputFunction('abs'), settings.hapticFeedback),
                      _sciChip('n!', () => notifier.inputOperator('!'), settings.hapticFeedback),
                      _sciChip('mod', () => notifier.inputOperator('%'), settings.hapticFeedback),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Row 2: Log, power, constants
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    children: [
                      _sciChip('ln', () => notifier.inputFunction('ln'), settings.hapticFeedback),
                      _sciChip('log', () => notifier.inputFunction('log'), settings.hapticFeedback),
                      _sciChip('√', () => notifier.inputFunction('sqrt'), settings.hapticFeedback),
                      _sciChip('x²', () => notifier.inputOperator('^2'), settings.hapticFeedback),
                      _sciChip('xʸ', () => notifier.inputOperator('^'), settings.hapticFeedback),
                      _sciChip('eˣ', () => notifier.inputConstant('e^('), settings.hapticFeedback),
                      _sciChip('10ˣ', () => notifier.inputConstant('10^('), settings.hapticFeedback),
                      _sciChip('π', () => notifier.inputConstant('π'), settings.hapticFeedback, isConstant: true),
                      _sciChip('e', () => notifier.inputConstant('e'), settings.hapticFeedback, isConstant: true),
                      _sciChip('rand', () {
                        final r = math.Random().nextDouble();
                        notifier.inputConstant(r.toStringAsFixed(6));
                      }, settings.hapticFeedback),
                      _sciChip('(', () => notifier.inputParenthesis('('), settings.hapticFeedback),
                      _sciChip(')', () => notifier.inputParenthesis(')'), settings.hapticFeedback),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Standard keypad (matches basic calculator layout)
          Flexible(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 10.0;
                  final cols = 4;
                  final rows = 5;
                  final totalHSpacing = spacing * (cols - 1);
                  final totalVSpacing = spacing * (rows - 1);
                  final btnW = (constraints.maxWidth - totalHSpacing) / cols;
                  final btnH = (constraints.maxHeight - totalVSpacing) / rows;

                  Widget btn(String label, CalcButtonType type, VoidCallback onTap,
                      {Widget? icon, double? fs}) {
                    return SizedBox(
                      width: btnW,
                      height: btnH,
                      child: CalcButton(
                        type: type,
                        onPressed: onTap,
                        hapticEnabled: settings.hapticFeedback,
                        child: icon ??
                            Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: fs ?? (type == CalcButtonType.tertiary ? 24 : 22),
                                fontWeight: FontWeight.w700,
                                color: _colorForType(type),
                              ),
                            ),
                      ),
                    );
                  }

                  Widget equalsBtn() {
                    return SizedBox(
                      width: btnW,
                      height: btnH,
                      child: Material(
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.primaryContainer],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              notifier.calculate(radianMode: settings.isRadianMode);
                              final n = ref.read(calculatorProvider.notifier);
                              if (n.lastExpression != null && n.lastResult != null) {
                                ref.read(historyProvider.notifier).addEntry(
                                  n.lastExpression!,
                                  n.lastResult!,
                                  'scientific',
                                );
                              }
                            },
                            child: Center(
                              child: Text(
                                '=',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Row 1: C DEL ( )
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          btn('C', CalcButtonType.error, () => notifier.clear()),
                          btn('', CalcButtonType.surface, () => notifier.delete(),
                              icon: Icon(Icons.backspace_outlined,
                                  color: AppColors.onSurface, size: 22)),
                          btn('( )', CalcButtonType.secondary, () => notifier.smartBracket()),
                          btn('÷', CalcButtonType.tertiary, () => notifier.inputOperator('÷')),
                        ],
                      ),
                      SizedBox(height: spacing),
                      // Row 2: 7 8 9 ×
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          btn('7', CalcButtonType.surface, () => notifier.inputDigit('7')),
                          btn('8', CalcButtonType.surface, () => notifier.inputDigit('8')),
                          btn('9', CalcButtonType.surface, () => notifier.inputDigit('9')),
                          btn('×', CalcButtonType.tertiary, () => notifier.inputOperator('×')),
                        ],
                      ),
                      SizedBox(height: spacing),
                      // Row 3: 4 5 6 -
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          btn('4', CalcButtonType.surface, () => notifier.inputDigit('4')),
                          btn('5', CalcButtonType.surface, () => notifier.inputDigit('5')),
                          btn('6', CalcButtonType.surface, () => notifier.inputDigit('6')),
                          btn('-', CalcButtonType.tertiary, () => notifier.inputOperator('-')),
                        ],
                      ),
                      SizedBox(height: spacing),
                      // Row 4: 1 2 3 +
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          btn('1', CalcButtonType.surface, () => notifier.inputDigit('1')),
                          btn('2', CalcButtonType.surface, () => notifier.inputDigit('2')),
                          btn('3', CalcButtonType.surface, () => notifier.inputDigit('3')),
                          btn('+', CalcButtonType.tertiary, () => notifier.inputOperator('+')),
                        ],
                      ),
                      SizedBox(height: spacing),
                      // Row 5: ± 0 . =
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          btn('±', CalcButtonType.surface, () => notifier.toggleSign()),
                          btn('0', CalcButtonType.surface, () => notifier.inputDigit('0')),
                          btn('.', CalcButtonType.surface, () => notifier.inputDecimal()),
                          equalsBtn(),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sciChip(String label, VoidCallback onTap, bool haptic,
      {bool isConstant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isConstant ? AppColors.primary : AppColors.secondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForType(CalcButtonType type) {
    switch (type) {
      case CalcButtonType.surface:
        return AppColors.onSurface;
      case CalcButtonType.tertiary:
        return AppColors.tertiary;
      case CalcButtonType.error:
        return AppColors.error;
      case CalcButtonType.primary:
        return AppColors.onPrimary;
      case CalcButtonType.secondary:
        return AppColors.secondary;
      case CalcButtonType.constant:
        return AppColors.primary;
    }
  }
}
