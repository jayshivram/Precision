import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum CalcButtonType { surface, tertiary, error, primary, secondary, constant }

class CalcButton extends StatelessWidget {
  final Widget child;
  final CalcButtonType type;
  final VoidCallback onPressed;
  final double? fontSize;

  const CalcButton({
    super.key,
    required this.child,
    required this.type,
    required this.onPressed,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (type) {
      case CalcButtonType.surface:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.onSurface;
        break;
      case CalcButtonType.tertiary:
        bg = AppColors.tertiaryContainer.withValues(alpha: 0.10);
        fg = AppColors.tertiary;
        break;
      case CalcButtonType.error:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.error;
        break;
      case CalcButtonType.primary:
        bg = AppColors.primary;
        fg = AppColors.onPrimary;
        break;
      case CalcButtonType.secondary:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.secondary;
        break;
      case CalcButtonType.constant:
        bg = AppColors.primary.withValues(alpha: 0.10);
        fg = AppColors.primary;
        break;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: fg.withValues(alpha: 0.15),
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Center(child: child),
      ),
    );
  }
}
