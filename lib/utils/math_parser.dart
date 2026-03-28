import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

class MathParser {
  static final GrammarParser _parser = GrammarParser();
  static final ContextModel _context = ContextModel();

  /// Evaluate a math expression string safely. Returns null on error.
  static double? evaluate(String expression, {bool radianMode = false}) {
    try {
      String sanitized = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', '(${math.pi})');

      // Replace standalone 'e' constant (not inside function names or numbers)
      sanitized = sanitized.replaceAllMapped(
        RegExp(r'(?<![a-zA-Z0-9])(e)(?![a-zA-Z0-9\^])'),
        (m) => '(${math.e})',
      );

      // Process factorials (e.g. "5!" => "120")
      sanitized = _processFactorials(sanitized);

      // Process percent: only trailing % after a number (not infix modulo a%b)
      sanitized = sanitized.replaceAllMapped(
        RegExp(r'(\d+\.?\d*)%(?![0-9.])'),
        (m) => '(${m.group(1)}/100)',
      );

      // Iteratively resolve all function calls (innermost first) using dart:math
      sanitized = _resolveAllFunctions(sanitized, radianMode);

      final exp = _parser.parse(sanitized);
      final result = exp.evaluate(EvaluationType.REAL, _context) as double;
      if (result.isNaN || result.isInfinite) return null;
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Regex pattern that matches the innermost fn(argWithNoParens).
  static final _fnCallPattern = RegExp(
    r'(asin|acos|atan|sin|cos|tan|sqrt|abs|log|ln|exp)\(([^()]+)\)',
  );

  /// Iteratively evaluate innermost function calls until none remain.
  static String _resolveAllFunctions(String expr, bool radianMode) {
    // Safety limit to prevent infinite loops on malformed input
    for (int iter = 0; iter < 100; iter++) {
      final match = _fnCallPattern.firstMatch(expr);
      if (match == null) break;

      final fnName = match.group(1)!;
      final argStr = match.group(2)!;

      // Evaluate the argument (pure arithmetic at this point)
      final argVal = _evalArithmetic(argStr);
      if (argVal == null) break;

      // Apply the function
      final result = _applyFunction(fnName, argVal, radianMode);
      if (result == null || result.isNaN || result.isInfinite) break;

      // Replace the matched fn(arg) with the numeric result
      expr = '${expr.substring(0, match.start)}($result)${expr.substring(match.end)}';
    }
    return expr;
  }

  /// Evaluate a pure arithmetic sub-expression via math_expressions.
  static double? _evalArithmetic(String expr) {
    try {
      final parsed = _parser.parse(expr);
      final result = parsed.evaluate(EvaluationType.REAL, _context) as double;
      if (result.isNaN || result.isInfinite) return null;
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Apply a named math function to a numeric argument.
  static double? _applyFunction(String fn, double x, bool radianMode) {
    switch (fn) {
      case 'sin':
        return math.sin(radianMode ? x : x * math.pi / 180);
      case 'cos':
        return math.cos(radianMode ? x : x * math.pi / 180);
      case 'tan':
        return math.tan(radianMode ? x : x * math.pi / 180);
      case 'asin':
        final r = math.asin(x);
        return radianMode ? r : r * 180 / math.pi;
      case 'acos':
        final r = math.acos(x);
        return radianMode ? r : r * 180 / math.pi;
      case 'atan':
        final r = math.atan(x);
        return radianMode ? r : r * 180 / math.pi;
      case 'sqrt':
        return math.sqrt(x);
      case 'abs':
        return x.abs();
      case 'log':
        return x > 0 ? math.log(x) / math.ln10 : null; // log₁₀
      case 'ln':
        return x > 0 ? math.log(x) : null; // natural log
      case 'exp':
        return math.exp(x);
      default:
        return null;
    }
  }

  static String _processFactorials(String expression) {
    return expression.replaceAllMapped(
      RegExp(r'(\d+)!'),
      (m) {
        final n = int.tryParse(m.group(1)!) ?? 0;
        if (n > 170) return 'Infinity';
        return _factorial(n).toString();
      },
    );
  }

  static double _factorial(int n) {
    if (n <= 1) return 1;
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
}
