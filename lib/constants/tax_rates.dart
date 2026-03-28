// Tanzania Provisional Tax Configuration
//
// To update tax brackets or rates when the law changes,
// simply modify the values below. No other code changes needed.

// ─── Sole Proprietor (Individual Income Tax) ────────────────────────────

/// Annual income below this amount is tax-free.
const double kSolePropNilThreshold = 3240000;

/// Tax brackets for sole proprietor income tax.
/// Each entry: (lowerBound, upperBound, marginal rate).
/// Brackets must be in ascending order and contiguous.
const List<(double, double, double)> kSolePropBrackets = [
  (3240000, 6240000, 0.08),
  (6240000, 9120000, 0.20),
  (9120000, 12000000, 0.25),
  (12000000, double.infinity, 0.30),
];

/// Pre-computed cumulative tax at the start of each bracket.
/// Update this if you change kSolePropBrackets.
const List<double> kSolePropCumulativeTax = [
  0, // up to 3,240,000
  240000, // (6,240,000 - 3,240,000) × 0.08
  816000, // 240,000 + (9,120,000 - 6,240,000) × 0.20
  1536000, // 816,000 + (12,000,000 - 9,120,000) × 0.25
];

// ─── Corporate Tax ──────────────────────────────────────────────────────

/// Flat corporate tax rate.
const double kCorporateTaxRate = 0.30;

// ─── Helpers ────────────────────────────────────────────────────────────

/// Calculate annual income tax for a sole proprietor given [profit].
double calculateSolePropTax(double profit) {
  if (profit <= kSolePropNilThreshold) return 0;

  double tax = 0;
  for (int i = 0; i < kSolePropBrackets.length; i++) {
    final (lower, upper, rate) = kSolePropBrackets[i];
    if (profit <= lower) break;
    final taxableInBracket =
        (profit > upper ? upper : profit) - lower;
    tax += taxableInBracket * rate;
  }
  return tax;
}

/// Reverse: given a desired [tax] amount, compute the profit that produces it.
double calculateSolePropProfitFromTax(double tax) {
  if (tax <= 0) return kSolePropNilThreshold;

  for (int i = 0; i < kSolePropBrackets.length; i++) {
    final cumTax = kSolePropCumulativeTax[i];
    final (lower, upper, rate) = kSolePropBrackets[i];
    final maxTaxInBracket = (upper == double.infinity)
        ? double.infinity
        : (upper - lower) * rate;

    if (tax <= cumTax + maxTaxInBracket) {
      return (tax - cumTax) / rate + lower;
    }
  }
  // Fallback (should not reach here with valid brackets)
  final lastRate = kSolePropBrackets.last.$3;
  final lastCum = kSolePropCumulativeTax.last;
  final lastLower = kSolePropBrackets.last.$1;
  return (tax - lastCum) / lastRate + lastLower;
}

/// Calculate annual corporate tax given [profit].
double calculateCorporateTax(double profit) {
  if (profit <= 0) return 0;
  return profit * kCorporateTaxRate;
}

/// Reverse: given a desired corporate [tax], compute the profit.
double calculateCorporateProfitFromTax(double tax) {
  if (tax <= 0) return 0;
  return tax / kCorporateTaxRate;
}
