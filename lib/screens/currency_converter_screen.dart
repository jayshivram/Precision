import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/api_keys.dart';
import '../constants/currencies.dart';
import '../providers/currency_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class CurrencyConverterScreen extends ConsumerStatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  ConsumerState<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends ConsumerState<CurrencyConverterScreen> {
  DateTime? _historicalDate;
  bool _showHistorical = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyProvider);
    final notifier = ref.read(currencyProvider.notifier);
    final fromInfo = getCurrencyByCode(state.fromCurrency);
    final toInfo = getCurrencyByCode(state.toCurrency);

    return SafeArea(
      child: Column(
        children: [
          // Status indicator
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state.isLoading
                          ? AppColors.tertiary
                          : (state.error != null ? AppColors.error : AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.isLoading
                        ? 'UPDATING...'
                        : state.lastUpdated != null
                            ? 'LIVE RATES — ${_formatTime(state.lastUpdated!)}'
                            : 'OFFLINE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Conversion display
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // From amount
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_currencySymbol(state.fromCurrency)}${PrecisionFormatter.formatCurrency(double.tryParse(state.amount.replaceAll(',', '')) ?? 0)} ${state.fromCurrency}',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // To amount
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_currencySymbol(state.toCurrency)}${PrecisionFormatter.formatCurrency(state.convertedAmount)}',
                      style: GoogleFonts.manrope(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Exchange rate
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '1 ${state.fromCurrency} = ${state.exchangeRate.toStringAsFixed(4)} ${state.toCurrency}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Currency selectors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _CurrencySelector(
                    info: fromInfo,
                    onTap: () => _showCurrencyPicker(context, (code) {
                      notifier.setFromCurrency(code);
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GestureDetector(
                    onTap: () => notifier.swap(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.swap_horiz, color: AppColors.primary, size: 24),
                    ),
                  ),
                ),
                Expanded(
                  child: _CurrencySelector(
                    info: toInfo,
                    onTap: () => _showCurrencyPicker(context, (code) {
                      notifier.setToCurrency(code);
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Amount display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: const Border(
                bottom: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AMOUNT',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${_currencySymbol(state.fromCurrency)}${PrecisionFormatter.formatCurrency(double.tryParse(state.amount.replaceAll(',', '')) ?? 0)}',
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Numeric keypad
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 8.0;
                  final cols = 3;
                  final rows = 4;
                  final btnW = (constraints.maxWidth - spacing * (cols - 1)) / cols;
                  final btnH = (constraints.maxHeight - spacing * (rows - 1) - 50) / rows;

                  Widget keyBtn(String label, VoidCallback onTap, {Widget? icon}) {
                    return SizedBox(
                      width: btnW,
                      height: btnH,
                      child: Material(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: onTap,
                          child: Center(
                            child: icon ??
                                Text(
                                  label,
                                  style: GoogleFonts.manrope(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          keyBtn('1', () => notifier.inputDigit('1')),
                          keyBtn('2', () => notifier.inputDigit('2')),
                          keyBtn('3', () => notifier.inputDigit('3')),
                        ],
                      ),
                      SizedBox(height: spacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          keyBtn('4', () => notifier.inputDigit('4')),
                          keyBtn('5', () => notifier.inputDigit('5')),
                          keyBtn('6', () => notifier.inputDigit('6')),
                        ],
                      ),
                      SizedBox(height: spacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          keyBtn('7', () => notifier.inputDigit('7')),
                          keyBtn('8', () => notifier.inputDigit('8')),
                          keyBtn('9', () => notifier.inputDigit('9')),
                        ],
                      ),
                      SizedBox(height: spacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          keyBtn('.', () => notifier.inputDecimal()),
                          keyBtn('0', () => notifier.inputDigit('0')),
                          keyBtn('', () => notifier.deleteDigit(),
                              icon: Icon(Icons.backspace_outlined,
                                  color: AppColors.error, size: 22)),
                        ],
                      ),
                      SizedBox(height: spacing),
                      // Refresh + Historical toggle row
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: Material(
                                borderRadius: BorderRadius.circular(12),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primary, AppColors.primaryContainer],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: state.isLoading ? null : () => notifier.refreshRates(),
                                    child: Center(
                                      child: state.isLoading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.onPrimary,
                                              ),
                                            )
                                          : Text(
                                              'REFRESH RATES',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 2,
                                                color: AppColors.onPrimary,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (kFreeCurrencyApiKey != 'YOUR_API_KEY_HERE') ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 42,
                              child: Material(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    setState(() => _showHistorical = !_showHistorical);
                                    if (_showHistorical) _pickDate(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Icon(Icons.history,
                                        color: _showHistorical
                                            ? AppColors.primary
                                            : AppColors.onSurfaceVariant,
                                        size: 20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Historical rate result
          if (_showHistorical && _historicalDate != null)
            _HistoricalRateDisplay(
              from: state.fromCurrency,
              to: state.toCurrency,
              date: _historicalDate!,
            ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime(1999, 1, 1),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surfaceContainerLow,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _historicalDate = picked);
    }
  }

  void _showCurrencyPicker(BuildContext context, ValueChanged<String> onSelected) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CurrencyPickerSheet(onSelected: onSelected),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _currencySymbol(String code) {
    const symbols = {
      'USD': '\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥',
      'CNY': '¥', 'INR': '₹', 'KRW': '₩', 'TRY': '₺',
      'RUB': '₽', 'THB': '฿', 'NGN': '₦', 'PHP': '₱',
      'KES': 'KSh', 'TZS': 'TSh', 'UGX': 'USh', 'ZMW': 'ZK',
    };
    return symbols[code] ?? '';
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  final ValueChanged<String> onSelected;
  const _CurrencyPickerSheet({required this.onSelected});

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CurrencyInfo> _filtered = kCurrencies;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? kCurrencies
          : kCurrencies
              .where((c) =>
                  c.code.toLowerCase().contains(q) ||
                  c.name.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'SELECT CURRENCY',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                autofocus: false,
                style: GoogleFonts.inter(
                  color: AppColors.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search currency or code\u2026',
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.onSurfaceVariant, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.onSurfaceVariant, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No currencies found',
                        style: GoogleFonts.inter(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final c = _filtered[index];
                        return ListTile(
                          leading: Text(c.flag,
                              style: const TextStyle(fontSize: 28)),
                          title: Text(
                            c.code,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            c.name,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          onTap: () {
                            widget.onSelected(c.code);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  final CurrencyInfo info;
  final VoidCallback onTap;

  const _CurrencySelector({required this.info, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(info.flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              info.code,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoricalRateDisplay extends ConsumerWidget {
  final String from;
  final String to;
  final DateTime date;

  const _HistoricalRateDisplay({
    required this.from,
    required this.to,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = HistoricalRateQuery(from: from, to: to, date: date);
    final rateAsync = ref.watch(historicalRateFutureProvider(query));
    final dateStr = '${date.day}/${date.month}/${date.year}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: rateAsync.when(
        data: (rate) {
          if (rate == null) {
            return Text('No data for $dateStr',
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 12));
          }
          return Text(
            'On $dateStr: 1 $from = ${rate.toStringAsFixed(4)} $to',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          );
        },
        loading: () => const Center(
          child: SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
          ),
        ),
        error: (e, _) => Text(
          'Could not fetch historical rate',
          style: GoogleFonts.inter(color: AppColors.error, fontSize: 12),
        ),
      ),
    );
  }
}
