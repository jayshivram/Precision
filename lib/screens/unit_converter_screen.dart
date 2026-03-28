import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/units.dart';
import '../providers/unit_converter_provider.dart';
import '../theme/app_theme.dart';
import '../utils/unit_conversion.dart';
import '../widgets/finance_calculator.dart';
import '../widgets/vat_calculator.dart';
import '../widgets/provisional_tax_calculator.dart';

class UnitConverterScreen extends ConsumerWidget {
  const UnitConverterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(unitConverterProvider);
    final notifier = ref.read(unitConverterProvider.notifier);
    final categories = kUnitsByCategory.keys.toList();
    final units = kUnitsByCategory[state.category] ?? [];

    return SafeArea(
      child: Column(
        children: [
          // Category chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (context2, index2) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isActive = cat == state.category;
                return GestureDetector(
                  onTap: () => notifier.setCategory(cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        cat.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Conversion area
          Expanded(
            child: state.category == 'Finance'
                ? const FinanceCalculator()
                : state.category == 'VAT'
                    ? const VATCalculator()
                    : state.category == 'Tax'
                        ? const ProvisionalTaxCalculator()
                        : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // From card
                  _ConversionCard(
                    label: 'INPUT VALUE',
                    value: state.fromValue,
                    unit: state.fromUnit,
                    units: units,
                    onUnitChanged: (u) => notifier.setFromUnit(u),
                    onValueChanged: (v) => notifier.setFromValue(v),
                    isInput: true,
                  ),
                  // Swap button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      onTap: () => notifier.swap(),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.swap_vert, color: AppColors.onPrimary, size: 24),
                      ),
                    ),
                  ),
                  // To card
                  _ConversionCard(
                    label: 'RESULTING UNIT',
                    value: state.toValue,
                    unit: state.toUnit,
                    units: units,
                    onUnitChanged: (u) => notifier.setToUnit(u),
                    isInput: false,
                  ),
                  const SizedBox(height: 16),
                  // Quick reference
                  Expanded(
                    child: _QuickReference(
                      category: state.category,
                      fromUnit: state.fromUnit,
                      fromValue: state.fromValue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversionCard extends StatefulWidget {
  final String label;
  final String value;
  final String unit;
  final List<String> units;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<String>? onValueChanged;
  final bool isInput;

  const _ConversionCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.units,
    required this.onUnitChanged,
    this.onValueChanged,
    required this.isInput,
  });

  @override
  State<_ConversionCard> createState() => _ConversionCardState();
}

class _ConversionCardState extends State<_ConversionCard> {
  TextEditingController? _textController;

  @override
  void initState() {
    super.initState();
    if (widget.isInput) {
      _textController = TextEditingController(text: widget.value);
    }
  }

  @override
  void didUpdateWidget(covariant _ConversionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_textController != null && oldWidget.value != widget.value) {
      final cursorPos = _textController!.selection.baseOffset;
      _textController!.text = widget.value;
      final newPos = cursorPos.clamp(0, widget.value.length);
      _textController!.selection = TextSelection.fromPosition(TextPosition(offset: newPos));
    }
  }

  @override
  void dispose() {
    _textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: widget.isInput
            ? null
            : Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              _UnitDropdown(
                value: widget.unit,
                units: widget.units,
                onChanged: widget.onUnitChanged,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.isInput)
            TextField(
              controller: _textController,
              onChanged: widget.onValueChanged,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              style: GoogleFonts.manrope(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: GoogleFonts.manrope(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.surfaceContainerHighest,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                widget.value.isEmpty ? '0' : widget.value,
                style: GoogleFonts.manrope(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: widget.isInput ? AppColors.onSurface : AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  final String value;
  final List<String> units;
  final ValueChanged<String> onChanged;

  const _UnitDropdown({
    required this.value,
    required this.units,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      color: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
      itemBuilder: (context) => units.map((u) {
        final name = kUnitNames[u] ?? u;
        return PopupMenuItem<String>(
          value: u,
          child: Row(
            children: [
              Text(
                u,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: u == value ? AppColors.primary : AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _QuickReference extends StatelessWidget {
  final String category;
  final String fromUnit;
  final String fromValue;

  const _QuickReference({
    required this.category,
    required this.fromUnit,
    required this.fromValue,
  });

  @override
  Widget build(BuildContext context) {
    final units = (kUnitsByCategory[category] ?? [])
        .where((u) => u != fromUnit)
        .take(6)
        .toList();
    final val = double.tryParse(fromValue.replaceAll(',', '')) ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK REFERENCE (${fromValue.isEmpty ? "1" : fromValue} $fromUnit)',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: units.length,
            itemBuilder: (context, index) {
              final u = units[index];
              final converted = UnitConversion.convert(
                val == 0 ? 1 : val,
                fromUnit,
                u,
                category,
              );
              String display;
              if (converted.abs() >= 1e8) {
                display = converted.toStringAsExponential(2);
              } else if (converted == converted.truncateToDouble()) {
                display = converted.toInt().toString();
              } else {
                display = converted.toStringAsFixed(4)
                    .replaceAll(RegExp(r'0+$'), '')
                    .replaceAll(RegExp(r'\.$'), '');
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      kUnitNames[u] ?? u,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      display,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
