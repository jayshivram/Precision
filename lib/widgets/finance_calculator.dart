import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class FinanceCalculator extends StatefulWidget {
  const FinanceCalculator({super.key});

  @override
  State<FinanceCalculator> createState() => _FinanceCalculatorState();
}

class _FinanceCalculatorState extends State<FinanceCalculator>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
              Tab(text: 'COMPOUND'),
              Tab(text: 'SIMPLE'),
              Tab(text: 'EMI'),
              Tab(text: 'SIP'),
              Tab(text: 'LUMPSUM'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _CompoundInterestTab(),
              _SimpleInterestTab(),
              _EMITab(),
              _SIPTab(),
              _LumpsumTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared helpers ─────────────────────────────────────────────────────

final _currencyFmt = NumberFormat('#,##0.00', 'en_US');

String _fmtCurrency(double v) => _currencyFmt.format(v);
String _fmtPercent(double v) => '${v.toStringAsFixed(2)}%';

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
      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

double? _parseNum(TextEditingController c) =>
    double.tryParse(c.text.replaceAll(',', ''));

// ─── Compound Interest Tab ──────────────────────────────────────────────

class _CompoundInterestTab extends StatefulWidget {
  const _CompoundInterestTab();
  @override
  State<_CompoundInterestTab> createState() => _CompoundInterestTabState();
}

class _CompoundInterestTabState extends State<_CompoundInterestTab>
    with AutomaticKeepAliveClientMixin {
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _time = TextEditingController();
  int _compounding = 1; // 1=annual, 4=quarterly, 12=monthly, 365=daily
  double? _finalAmount, _totalInterest, _roi;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _principal.dispose();
    _rate.dispose();
    _time.dispose();
    super.dispose();
  }

  void _calculate() {
    final p = _parseNum(_principal);
    final r = _parseNum(_rate);
    final t = _parseNum(_time);
    if (p == null || r == null || t == null || p <= 0) return;
    final n = _compounding;
    final amount = p * math.pow(1 + r / (100 * n), n * t);
    setState(() {
      _finalAmount = amount;
      _totalInterest = amount - p;
      _roi = ((amount - p) / p) * 100;
    });
  }

  static const _compoundLabels = {
    1: 'Annually',
    4: 'Quarterly',
    12: 'Monthly',
    365: 'Daily',
  };

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _inputField(controller: _principal, label: 'Principal Amount'),
        _inputField(controller: _rate, label: 'Annual Rate', suffix: '%'),
        _inputField(controller: _time, label: 'Time Period', suffix: 'years'),
        // Compounding selector
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Wrap(
            spacing: 8,
            children: _compoundLabels.entries.map((e) {
              final isActive = _compounding == e.key;
              return GestureDetector(
                onTap: () => setState(() => _compounding = e.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                    border: isActive
                        ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Text(
                    e.value,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        _calcButton(_calculate),
        if (_finalAmount != null) ...[
          const SizedBox(height: 16),
          _resultCard('Final Amount', _fmtCurrency(_finalAmount!)),
          const SizedBox(height: 8),
          _resultCard('Total Interest', _fmtCurrency(_totalInterest!),
              valueColor: AppColors.tertiary),
          const SizedBox(height: 8),
          _resultCard('ROI', _fmtPercent(_roi!),
              valueColor: AppColors.secondary),
        ],
      ],
    );
  }
}

// ─── Simple Interest Tab ────────────────────────────────────────────────

class _SimpleInterestTab extends StatefulWidget {
  const _SimpleInterestTab();
  @override
  State<_SimpleInterestTab> createState() => _SimpleInterestTabState();
}

class _SimpleInterestTabState extends State<_SimpleInterestTab>
    with AutomaticKeepAliveClientMixin {
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _time = TextEditingController();
  double? _interest, _finalAmount, _roi;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _principal.dispose();
    _rate.dispose();
    _time.dispose();
    super.dispose();
  }

  void _calculate() {
    final p = _parseNum(_principal);
    final r = _parseNum(_rate);
    final t = _parseNum(_time);
    if (p == null || r == null || t == null || p <= 0) return;
    final interest = p * r * t / 100;
    setState(() {
      _interest = interest;
      _finalAmount = p + interest;
      _roi = (interest / p) * 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _inputField(controller: _principal, label: 'Principal Amount'),
        _inputField(controller: _rate, label: 'Annual Rate', suffix: '%'),
        _inputField(controller: _time, label: 'Time Period', suffix: 'years'),
        _calcButton(_calculate),
        if (_interest != null) ...[
          const SizedBox(height: 16),
          _resultCard('Interest', _fmtCurrency(_interest!),
              valueColor: AppColors.tertiary),
          const SizedBox(height: 8),
          _resultCard('Final Amount', _fmtCurrency(_finalAmount!)),
          const SizedBox(height: 8),
          _resultCard('ROI', _fmtPercent(_roi!),
              valueColor: AppColors.secondary),
        ],
      ],
    );
  }
}

// ─── EMI Tab ────────────────────────────────────────────────────────────

class _EMITab extends StatefulWidget {
  const _EMITab();
  @override
  State<_EMITab> createState() => _EMITabState();
}

class _EMITabState extends State<_EMITab>
    with AutomaticKeepAliveClientMixin {
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _tenure = TextEditingController();
  double? _emi, _totalPayment, _totalInterest;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _principal.dispose();
    _rate.dispose();
    _tenure.dispose();
    super.dispose();
  }

  void _calculate() {
    final p = _parseNum(_principal);
    final r = _parseNum(_rate);
    final n = _parseNum(_tenure);
    if (p == null || r == null || n == null || p <= 0 || n <= 0) return;
    if (r == 0) {
      // Zero interest: simple division
      setState(() {
        _emi = p / n;
        _totalPayment = p;
        _totalInterest = 0;
      });
      return;
    }
    final rm = r / (12 * 100);
    final pow = math.pow(1 + rm, n);
    final emi = p * rm * pow / (pow - 1);
    setState(() {
      _emi = emi;
      _totalPayment = emi * n;
      _totalInterest = emi * n - p;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _inputField(controller: _principal, label: 'Loan Amount'),
        _inputField(controller: _rate, label: 'Annual Interest Rate', suffix: '%'),
        _inputField(controller: _tenure, label: 'Tenure', suffix: 'months'),
        _calcButton(_calculate),
        if (_emi != null) ...[
          const SizedBox(height: 16),
          _resultCard('Monthly EMI', _fmtCurrency(_emi!)),
          const SizedBox(height: 8),
          _resultCard('Total Payment', _fmtCurrency(_totalPayment!),
              valueColor: AppColors.tertiary),
          const SizedBox(height: 8),
          _resultCard('Total Interest', _fmtCurrency(_totalInterest!),
              valueColor: AppColors.secondary),
        ],
      ],
    );
  }
}

// ─── SIP Tab ────────────────────────────────────────────────────────────

class _SIPTab extends StatefulWidget {
  const _SIPTab();
  @override
  State<_SIPTab> createState() => _SIPTabState();
}

class _SIPTabState extends State<_SIPTab>
    with AutomaticKeepAliveClientMixin {
  final _monthly = TextEditingController();
  final _rate = TextEditingController();
  final _time = TextEditingController();
  double? _futureValue, _totalInvested, _totalReturns;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _monthly.dispose();
    _rate.dispose();
    _time.dispose();
    super.dispose();
  }

  void _calculate() {
    final m = _parseNum(_monthly);
    final r = _parseNum(_rate);
    final t = _parseNum(_time);
    if (m == null || r == null || t == null || m <= 0) return;
    final n = (t * 12).toInt();
    final invested = m * n;
    if (r == 0) {
      setState(() {
        _futureValue = invested;
        _totalInvested = invested;
        _totalReturns = 0;
      });
      return;
    }
    final rm = r / (12 * 100);
    final fv = m * ((math.pow(1 + rm, n) - 1) / rm) * (1 + rm);
    setState(() {
      _futureValue = fv;
      _totalInvested = invested;
      _totalReturns = fv - invested;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _inputField(controller: _monthly, label: 'Monthly Investment'),
        _inputField(controller: _rate, label: 'Expected Annual Return', suffix: '%'),
        _inputField(controller: _time, label: 'Time Period', suffix: 'years'),
        _calcButton(_calculate),
        if (_futureValue != null) ...[
          const SizedBox(height: 16),
          _resultCard('Future Value', _fmtCurrency(_futureValue!)),
          const SizedBox(height: 8),
          _resultCard('Total Invested', _fmtCurrency(_totalInvested!),
              valueColor: AppColors.tertiary),
          const SizedBox(height: 8),
          _resultCard('Total Returns', _fmtCurrency(_totalReturns!),
              valueColor: AppColors.secondary),
        ],
      ],
    );
  }
}

// ─── Lumpsum Tab ────────────────────────────────────────────────────────

class _LumpsumTab extends StatefulWidget {
  const _LumpsumTab();
  @override
  State<_LumpsumTab> createState() => _LumpsumTabState();
}

class _LumpsumTabState extends State<_LumpsumTab>
    with AutomaticKeepAliveClientMixin {
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _time = TextEditingController();
  double? _futureValue, _totalReturns, _roi;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _principal.dispose();
    _rate.dispose();
    _time.dispose();
    super.dispose();
  }

  void _calculate() {
    final p = _parseNum(_principal);
    final r = _parseNum(_rate);
    final t = _parseNum(_time);
    if (p == null || r == null || t == null || p <= 0) return;
    final fv = p * math.pow(1 + r / 100, t);
    setState(() {
      _futureValue = fv;
      _totalReturns = fv - p;
      _roi = ((fv - p) / p) * 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _inputField(controller: _principal, label: 'Investment Amount'),
        _inputField(controller: _rate, label: 'Annual Return Rate', suffix: '%'),
        _inputField(controller: _time, label: 'Time Period', suffix: 'years'),
        _calcButton(_calculate),
        if (_futureValue != null) ...[
          const SizedBox(height: 16),
          _resultCard('Future Value', _fmtCurrency(_futureValue!)),
          const SizedBox(height: 8),
          _resultCard('Total Returns', _fmtCurrency(_totalReturns!),
              valueColor: AppColors.tertiary),
          const SizedBox(height: 8),
          _resultCard('ROI', _fmtPercent(_roi!),
              valueColor: AppColors.secondary),
        ],
      ],
    );
  }
}
