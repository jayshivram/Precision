import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class VATCalculator extends StatefulWidget {
  const VATCalculator({super.key});

  @override
  State<VATCalculator> createState() => _VATCalculatorState();
}

class _VATCalculatorState extends State<VATCalculator> {
  final _amountController = TextEditingController();
  final _vatRateController = TextEditingController(text: '18');
  bool _isInclusive = false; // false = exclusive (price before VAT)

  static final _fmt = NumberFormat('#,##0.00', 'en_US');

  @override
  void dispose() {
    _amountController.dispose();
    _vatRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Live calculation
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    final rate =
        double.tryParse(_vatRateController.text.replaceAll(',', '')) ?? 0;

    double netAmount, vatAmount, grossAmount;

    if (_isInclusive) {
      // Amount entered is gross (incl. VAT)
      grossAmount = amount;
      vatAmount = rate > 0 ? amount * rate / (100 + rate) : 0;
      netAmount = grossAmount - vatAmount;
    } else {
      // Amount entered is net (excl. VAT)
      netAmount = amount;
      vatAmount = amount * rate / 100;
      grossAmount = netAmount + vatAmount;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // VAT Rate input
          TextField(
            controller: _vatRateController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'VAT Rate',
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
              suffixText: '%',
              suffixStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 10),

          // Amount input
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [ThousandsInputFormatter()],
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              labelText: _isInclusive ? 'Amount (incl. VAT)' : 'Amount (excl. VAT)',
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),

          // Mode toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isInclusive = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isInclusive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: !_isInclusive
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5))
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'EXCLUSIVE',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: !_isInclusive
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isInclusive = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isInclusive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: _isInclusive
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5))
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'INCLUSIVE',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: _isInclusive
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Results — always visible, computed live
          if (amount > 0) ...[
            _vatResultCard('Net Amount', _fmt.format(netAmount),
                subtitle: 'Price excl. VAT'),
            const SizedBox(height: 8),
            _vatResultCard('VAT Amount', _fmt.format(vatAmount),
                subtitle: '${rate.toStringAsFixed(rate.truncateToDouble() == rate ? 0 : 2)}% of net',
                valueColor: AppColors.tertiary),
            const SizedBox(height: 8),
            _vatResultCard('Gross Amount', _fmt.format(grossAmount),
                subtitle: 'Price incl. VAT',
                valueColor: AppColors.primary),
          ],
        ],
      ),
    );
  }

  Widget _vatResultCard(String label, String value,
      {String? subtitle, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
