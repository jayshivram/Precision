import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/tax_rates.dart';
import '../theme/app_theme.dart';

class ProvisionalTaxCalculator extends StatefulWidget {
  const ProvisionalTaxCalculator({super.key});

  @override
  State<ProvisionalTaxCalculator> createState() =>
      _ProvisionalTaxCalculatorState();
}

class _ProvisionalTaxCalculatorState extends State<ProvisionalTaxCalculator>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 36,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            labelStyle: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
            tabs: const [
              Tab(text: 'SOLE PROPRIETOR'),
              Tab(text: 'CORPORATE'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _SolePropTab(),
              _CorporateTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared helpers ─────────────────────────────────────────────────────

final _currencyFmt = NumberFormat('#,##0.00', 'en_US');

String _fmtTZS(double v) => 'TZS ${_currencyFmt.format(v)}';

double? _parseNum(TextEditingController c) =>
    double.tryParse(c.text.replaceAll(',', ''));

Widget _inputField({
  required TextEditingController controller,
  required String label,
  String? suffix,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
        suffixText: suffix,
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
  );
}

Widget _resultCard(String label, String value, {Color? valueColor}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      border:
          Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.primary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}

Widget _calcButton(VoidCallback onTap) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: Material(
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(
              'CALCULATE',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _modeToggle({
  required bool isReverse,
  required String forwardLabel,
  required String reverseLabel,
  required ValueChanged<bool> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !isReverse
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: !isReverse
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5))
                    : null,
              ),
              child: Center(
                child: Text(
                  forwardLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: !isReverse
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
            onTap: () => onChanged(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isReverse
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: isReverse
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5))
                    : null,
              ),
              child: Center(
                child: Text(
                  reverseLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isReverse
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
  );
}

// ─── Sole Proprietor Tab ────────────────────────────────────────────────

class _SolePropTab extends StatefulWidget {
  const _SolePropTab();
  @override
  State<_SolePropTab> createState() => _SolePropTabState();
}

class _SolePropTabState extends State<_SolePropTab>
    with AutomaticKeepAliveClientMixin {
  final _input = TextEditingController();
  bool _isReverse = false; // false = profit→tax, true = tax→profit

  double? _annualTax;
  double? _quarterlyTax;
  double? _profit;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _calculate() {
    final val = _parseNum(_input);
    if (val == null || val < 0) return;

    if (_isReverse) {
      // From desired tax → profit
      final profit = calculateSolePropProfitFromTax(val);
      final annualTax = val;
      setState(() {
        _profit = profit;
        _annualTax = annualTax;
        _quarterlyTax = annualTax / 4;
      });
    } else {
      // From profit → tax
      final tax = calculateSolePropTax(val);
      setState(() {
        _profit = val;
        _annualTax = tax;
        _quarterlyTax = tax / 4;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tanzania Individual Income Tax',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),

        _modeToggle(
          isReverse: _isReverse,
          forwardLabel: 'PROFIT → TAX',
          reverseLabel: 'TAX → PROFIT',
          onChanged: (v) => setState(() {
            _isReverse = v;
            _annualTax = null;
            _quarterlyTax = null;
            _profit = null;
          }),
        ),

        _inputField(
          controller: _input,
          label: _isReverse ? 'Desired Annual Tax (TZS)' : 'Annual Profit (TZS)',
        ),
        _calcButton(_calculate),

        if (_annualTax != null) ...[
          const SizedBox(height: 16),
          if (_isReverse) ...[
            _resultCard('Required Profit', _fmtTZS(_profit!)),
            const SizedBox(height: 8),
          ],
          _resultCard('Annual Tax', _fmtTZS(_annualTax!),
              valueColor: AppColors.tertiary),
          const SizedBox(height: 8),
          _resultCard('Quarterly Tax', _fmtTZS(_quarterlyTax!),
              valueColor: AppColors.secondary),
        ],
      ],
    );
  }
}

// ─── Corporate Tab ──────────────────────────────────────────────────────

class _CorporateTab extends StatefulWidget {
  const _CorporateTab();
  @override
  State<_CorporateTab> createState() => _CorporateTabState();
}

class _CorporateTabState extends State<_CorporateTab>
    with AutomaticKeepAliveClientMixin {
  final _input = TextEditingController();
  bool _isReverse = false;

  double? _annualTax;
  double? _quarterlyTax;
  double? _profit;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _calculate() {
    final val = _parseNum(_input);
    if (val == null || val < 0) return;

    if (_isReverse) {
      final profit = calculateCorporateProfitFromTax(val);
      setState(() {
        _profit = profit;
        _annualTax = val;
        _quarterlyTax = val / 4;
      });
    } else {
      final tax = calculateCorporateTax(val);
      setState(() {
        _profit = val;
        _annualTax = tax;
        _quarterlyTax = tax / 4;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tanzania Corporate Tax (${(kCorporateTaxRate * 100).toStringAsFixed(0)}%)',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),

        _modeToggle(
          isReverse: _isReverse,
          forwardLabel: 'PROFIT → TAX',
          reverseLabel: 'TAX → PROFIT',
          onChanged: (v) => setState(() {
            _isReverse = v;
            _annualTax = null;
            _quarterlyTax = null;
            _profit = null;
          }),
        ),

        _inputField(
          controller: _input,
          label: _isReverse ? 'Desired Annual Tax (TZS)' : 'Annual Profit (TZS)',
        ),
        _calcButton(_calculate),

        if (_annualTax != null) ...[
          const SizedBox(height: 16),
          if (_isReverse) ...[
            _resultCard('Required Profit', _fmtTZS(_profit!)),
            const SizedBox(height: 8),
          ],
          _resultCard('Annual Tax', _fmtTZS(_annualTax!),
              valueColor: AppColors.tertiary),
          const SizedBox(height: 8),
          _resultCard('Quarterly Tax', _fmtTZS(_quarterlyTax!),
              valueColor: AppColors.secondary),
        ],
      ],
    );
  }
}
