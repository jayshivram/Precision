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
      // User's 'log' = log₁₀, user's 'ln' = natural log
      // _wrapFunction handles nested brackets correctly
      sanitized = _wrapFunction(sanitized, 'log', (x) => '(log($x)/${math.ln10})');
      sanitized = _wrapFunction(sanitized, 'ln', (x) => 'log($x)');

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
      // Inverse trig first: output in degrees (rad→deg)
      for (final fn in ['asin', 'acos', 'atan']) {
        expr = _wrapFunction(expr, fn, (content) => '((180/${math.pi})*$fn($content))');
      }
      // Forward trig: input in degrees (deg→rad conversion on argument)
      for (final fn in ['sin', 'cos', 'tan']) {
        expr = _wrapFunction(expr, fn, (content) => '$fn((${math.pi}/180)*$content)');
      }
    }
    return expr;
  }

  /// Replaces all top-level occurrences of `fnName(...)` in [expr] with
  /// [transform(innerContent)], correctly handling arbitrarily nested brackets.
  /// For sin/cos/tan, skips matches preceded by 'a' (avoids matching asin/acos/atan).
  static String _wrapFunction(
      String expr, String fnName, String Function(String) transform) {
    final sb = StringBuffer();
    final tag = '$fnName(';
    final isForwardTrig = fnName == 'sin' || fnName == 'cos' || fnName == 'tan';
    int i = 0;
    while (i < expr.length) {
      if (expr.startsWith(tag, i)) {
        // For sin/cos/tan, skip if preceded by 'a' (i.e. it is asin/acos/atan)
        if (isForwardTrig && i > 0 && expr[i - 1] == 'a') {
          sb.write(expr[i]);
          i++;
          continue;
        }
        i += tag.length; // skip fnName and opening '('
        int depth = 1;
        final start = i;
        while (i < expr.length && depth > 0) {
          if (expr[i] == '(') depth++;
          else if (expr[i] == ')') depth--;
          i++;
        }
        final content = expr.substring(start, i - 1);
        sb.write(transform(content));
      } else {
        sb.write(expr[i]);
        i++;
      }
    }
    return sb.toString();
  }
}
