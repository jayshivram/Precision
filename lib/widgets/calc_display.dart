import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CalcDisplay extends StatelessWidget {
  final String expression;
  final String display;
  final String? error;

  const CalcDisplay({
    super.key,
    required this.expression,
    required this.display,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Expression line
          SizedBox(
            height: 32,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                expression.isEmpty ? ' ' : expression,
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Result line
          SizedBox(
            height: 64,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                error ?? display,
                style: GoogleFonts.manrope(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: error != null ? AppColors.error : Colors.white,
                ),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.outlineVariant.withValues(alpha: 0.10),
          ),
        ],
      ),
    );
  }
}
