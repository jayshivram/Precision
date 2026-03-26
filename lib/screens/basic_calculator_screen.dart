import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/calc_button.dart';
import '../widgets/calc_display.dart';

class BasicCalculatorScreen extends ConsumerWidget {
  const BasicCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          // Display area
          Flexible(
            flex: 3,
            child: CalcDisplay(
              expression: state.hasResult
                  ? state.expression
                  : (state.previewResult != null
                      ? '= ${state.previewResult}'
                      : ''),
              display: state.display,
              error: state.error,
            ),
          ),
          const SizedBox(height: 8),
          // Button grid
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
                      {Widget? icon}) {
                    return SizedBox(
                      width: btnW,
                      height: btnH,
                      child: CalcButton(
                        type: type,
                        onPressed: onTap,
                        child: icon ??
                            Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: type == CalcButtonType.tertiary ? 24 : 22,
                                fontWeight: FontWeight.w700,
                                color: _colorForType(type),
                              ),
                            ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Row 1: C DEL ( ) ÷
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
                      // Row 5: % 0 . =
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          btn('%', CalcButtonType.surface, () => notifier.inputOperator('%')),
                          btn('0', CalcButtonType.surface, () => notifier.inputDigit('0')),
                          btn('.', CalcButtonType.surface, () => notifier.inputDecimal()),
                          SizedBox(
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
                                    notifier.calculate();
                                    final n = ref.read(calculatorProvider.notifier);
                                    if (n.lastExpression != null && n.lastResult != null) {
                                      ref.read(historyProvider.notifier).addEntry(
                                        n.lastExpression!,
                                        n.lastResult!,
                                        'basic',
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
                          ),
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
