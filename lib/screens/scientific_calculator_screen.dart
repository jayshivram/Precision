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
            flex: 2,
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
                    height: 24,
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
                          fontSize: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        state.error ?? state.display,
                        style: GoogleFonts.manrope(
                          fontSize: 44,
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
          // Button grid
          Flexible(
            flex: 7,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final spacing = 6.0;
                final cols = 5;
                final rows = 8;
                final btnW = (constraints.maxWidth - spacing * (cols - 1) - 12) / cols;
                final btnH = (constraints.maxHeight - spacing * (rows - 1) - 8) / rows;

                Widget btn(String label, CalcButtonType type, VoidCallback onTap, {double? fs}) {
                  return SizedBox(
                    width: btnW,
                    height: btnH,
                    child: CalcButton(
                      type: type,
                      onPressed: onTap,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: fs ?? (type == CalcButtonType.surface ? 18 : 13),
                              fontWeight: FontWeight.w600,
                              color: _colorForType(type),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                Widget iconBtn(CalcButtonType type, VoidCallback onTap, IconData icon) {
                  return SizedBox(
                    width: btnW,
                    height: btnH,
                    child: CalcButton(
                      type: type,
                      onPressed: onTap,
                      child: Icon(icon, color: _colorForType(type), size: 20),
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
                            colors: [AppColors.primary, AppColors.primaryContainer],
                          ),
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
                            child: Text('=',
                              style: GoogleFonts.inter(
                                fontSize: 24, fontWeight: FontWeight.w700,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                List<Widget> row(List<Widget> children) {
                  return [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: children,
                    ),
                    SizedBox(height: spacing),
                  ];
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Column(
                    children: [
                      // Row 1: sin cos tan ( )
                      ...row([
                        btn('sin', CalcButtonType.secondary, () => notifier.inputFunction('sin')),
                        btn('cos', CalcButtonType.secondary, () => notifier.inputFunction('cos')),
                        btn('tan', CalcButtonType.secondary, () => notifier.inputFunction('tan')),
                        btn('(', CalcButtonType.secondary, () => notifier.inputParenthesis('(')),
                        btn(')', CalcButtonType.secondary, () => notifier.inputParenthesis(')')),
                      ]),
                      // Row 2: sin⁻¹ cos⁻¹ tan⁻¹ xʸ √
                      ...row([
                        btn('sin⁻¹', CalcButtonType.secondary, () => notifier.inputFunction('asin')),
                        btn('cos⁻¹', CalcButtonType.secondary, () => notifier.inputFunction('acos')),
                        btn('tan⁻¹', CalcButtonType.secondary, () => notifier.inputFunction('atan')),
                        btn('xʸ', CalcButtonType.secondary, () => notifier.inputOperator('^')),
                        btn('√', CalcButtonType.secondary, () => notifier.inputFunction('sqrt')),
                      ]),
                      // Row 3: ln log eˣ 10ˣ x²
                      ...row([
                        btn('ln', CalcButtonType.secondary, () => notifier.inputFunction('ln')),
                        btn('log', CalcButtonType.secondary, () => notifier.inputFunction('log')),
                        btn('eˣ', CalcButtonType.secondary, () {
                          notifier.inputConstant('e^(');
                        }),
                        btn('10ˣ', CalcButtonType.secondary, () {
                          notifier.inputConstant('10^(');
                        }),
                        btn('x²', CalcButtonType.secondary, () => notifier.inputOperator('^2')),
                      ]),
                      // Row 4: π e |x| n! rand
                      ...row([
                        btn('π', CalcButtonType.constant, () => notifier.inputConstant('π')),
                        btn('e', CalcButtonType.constant, () => notifier.inputConstant('e')),
                        btn('|x|', CalcButtonType.secondary, () => notifier.inputFunction('abs')),
                        btn('n!', CalcButtonType.secondary, () => notifier.inputOperator('!')),
                        btn('rand', CalcButtonType.secondary, () {
                          final r = math.Random().nextDouble();
                          notifier.inputConstant(r.toStringAsFixed(6));
                        }),
                      ]),
                      // Row 5: C DEL mod 0 ÷
                      ...row([
                        btn('C', CalcButtonType.error, () => notifier.clear()),
                        iconBtn(CalcButtonType.surface, () => notifier.delete(), Icons.backspace_outlined),
                        btn('mod', CalcButtonType.secondary, () => notifier.inputOperator('%')),
                        btn('0', CalcButtonType.surface, () => notifier.inputDigit('0'), fs: 20),
                        btn('÷', CalcButtonType.tertiary, () => notifier.inputOperator('÷'), fs: 22),
                      ]),
                      // Row 6: 7 8 9 × +/-
                      ...row([
                        btn('7', CalcButtonType.surface, () => notifier.inputDigit('7'), fs: 20),
                        btn('8', CalcButtonType.surface, () => notifier.inputDigit('8'), fs: 20),
                        btn('9', CalcButtonType.surface, () => notifier.inputDigit('9'), fs: 20),
                        btn('×', CalcButtonType.tertiary, () => notifier.inputOperator('×'), fs: 22),
                        btn('±', CalcButtonType.surface, () => notifier.toggleSign()),
                      ]),
                      // Row 7: 4 5 6 - .
                      ...row([
                        btn('4', CalcButtonType.surface, () => notifier.inputDigit('4'), fs: 20),
                        btn('5', CalcButtonType.surface, () => notifier.inputDigit('5'), fs: 20),
                        btn('6', CalcButtonType.surface, () => notifier.inputDigit('6'), fs: 20),
                        btn('-', CalcButtonType.tertiary, () => notifier.inputOperator('-'), fs: 22),
                        btn('.', CalcButtonType.surface, () => notifier.inputDecimal(), fs: 20),
                      ]),
                      // Row 8: 1 2 3 + =
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          btn('1', CalcButtonType.surface, () => notifier.inputDigit('1'), fs: 20),
                          btn('2', CalcButtonType.surface, () => notifier.inputDigit('2'), fs: 20),
                          btn('3', CalcButtonType.surface, () => notifier.inputDigit('3'), fs: 20),
                          btn('+', CalcButtonType.tertiary, () => notifier.inputOperator('+'), fs: 22),
                          equalsBtn(),
                        ],
                      ),
                    ],
                  ),
                );
              },
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
