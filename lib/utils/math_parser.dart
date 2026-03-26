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
        RegExp(r'(?<![a-zA-Z0-9])(e)(?![a-zA-Z0-9])'),
        (m) => '(${math.e})',
      );

      // Handle log/ln: math_expressions 'log' = natural log
      // User's 'log' means log₁₀, user's 'ln' means natural log
      // First: mark user's log₁₀ calls, then convert ln to log
      sanitized = sanitized.replaceAll('log(', 'LOG10(');
      sanitized = sanitized.replaceAll('ln(', 'log(');
      // Expand LOG10(x) → (log(x)/log(10)) using change of base
      sanitized = sanitized.replaceAllMapped(
        RegExp(r'LOG10\(([^)]+)\)'),
        (m) => '(log(${m.group(1)})/${math.ln10})',
      );

      // Process factorials (e.g. "5!" => "120")
      sanitized = _processFactorials(sanitized);

      // Process percent: standalone "%" at end of number
      sanitized = sanitized.replaceAllMapped(
        RegExp(r'(\d+\.?\d*)%'),
        (m) => '(${m.group(1)}/100)',
      );

      // Process special functions
      sanitized = _processSpecialFunctions(sanitized, radianMode);

      final exp = _parser.parse(sanitized);
      final result = exp.evaluate(EvaluationType.REAL, _context) as double;
      if (result.isNaN || result.isInfinite) return null;
      return result;
    } catch (_) {
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

  static String _processSpecialFunctions(String expr, bool radianMode) {
    if (!radianMode) {
      // Inverse trig first: wrap result with rad-to-deg conversion
      expr = expr.replaceAllMapped(
        RegExp(r'(asin|acos|atan)\(([^)]+)\)'),
        (m) => '((180/${math.pi})*${m.group(1)}(${m.group(2)}))',
      );
      // Forward trig: wrap argument with deg-to-rad conversion
      expr = expr.replaceAllMapped(
        RegExp(r'(?<!a)(sin|cos|tan)\(([^)]+)\)'),
        (m) => '${m.group(1)}((${math.pi}/180)*${m.group(2)})',
      );
    }

    return expr;
  }
}
