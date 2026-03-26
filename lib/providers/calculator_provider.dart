import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../utils/math_parser.dart';

class CalculatorState {
  final String expression;
  final String display;
  final bool hasResult;
  final String? error;
  final String? previewResult;

  const CalculatorState({
    this.expression = '',
    this.display = '0',
    this.hasResult = false,
    this.error,
    this.previewResult,
  });

  CalculatorState copyWith({
    String? expression,
    String? display,
    bool? hasResult,
    String? error,
    String? previewResult,
    bool clearPreview = false,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      display: display ?? this.display,
      hasResult: hasResult ?? this.hasResult,
      error: error,
      previewResult: clearPreview ? null : (previewResult ?? this.previewResult),
    );
  }
}

final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier();
});

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(const CalculatorState());

  String? _lastExpression;
  String? _lastResult;
  bool _radianMode = false;

  String? get lastExpression => _lastExpression;
  String? get lastResult => _lastResult;

  void updateRadianMode(bool v) => _radianMode = v;

  // Adds commas to each number in the expression string.
  // Only the integer part gets commas; decimals stay untouched.
  static String _formatDisplay(String expr) {
    if (expr.isEmpty) return '0';
    final formatter = NumberFormat('#,##0', 'en_US');
    return expr.replaceAllMapped(
      RegExp(r'\d+\.?\d*'),
      (m) {
        final raw = m[0]!;
        if (raw.contains('.')) {
          final parts = raw.split('.');
          final intVal = int.tryParse(parts[0]);
          final intStr = intVal != null ? formatter.format(intVal) : parts[0];
          return '$intStr.${parts[1]}';
        }
        final intVal = int.tryParse(raw);
        return intVal != null ? formatter.format(intVal) : raw;
      },
    );
  }

  // Format a computed result value with commas.
  static String _formatResult(double result) {
    final formatter = NumberFormat('#,##0', 'en_US');
    if (result == result.truncateToDouble() && result.abs() < 1e15) {
      return formatter.format(result.toInt());
    }
    String display = result.toStringAsFixed(8);
    if (display.contains('.')) {
      display = display.replaceAll(RegExp(r'0+$'), '');
      display = display.replaceAll(RegExp(r'\.$'), '');
    }
    return _formatDisplay(display);
  }

  // Silently evaluate the current expression for a live preview.
  // Returns null if expression is incomplete / invalid / just a bare number.
  String? _computePreview(String expr) {
    if (expr.isEmpty) return null;
    // Only show preview when there's at least one operator or function call
    final hasOp = RegExp(r'[+\-×÷^%]').hasMatch(expr);
    final hasFn = expr.contains('(');
    if (!hasOp && !hasFn) return null;
    // Don't preview if the expression ends with an operator
    if (RegExp(r'[+\-×÷^%(]$').hasMatch(expr)) return null;
    final result = MathParser.evaluate(expr, radianMode: _radianMode);
    if (result == null || result.isNaN || result.isInfinite) return null;
    return _formatResult(result);
  }

  void inputDigit(String digit) {
    if (state.hasResult) {
      state = CalculatorState(
        expression: digit,
        display: digit,
        previewResult: null,
      );
      return;
    }
    final newExpr = state.expression + digit;
    state = state.copyWith(
      expression: newExpr,
      display: _formatDisplay(newExpr),
      previewResult: _computePreview(newExpr),
    );
  }

  void inputOperator(String op) {
    if (state.hasResult) {
      // Strip commas from displayed result before using as raw expression
      final raw = state.display.replaceAll(',', '');
      final newExpr = raw + op;
      state = CalculatorState(
        expression: newExpr,
        display: _formatDisplay(newExpr),
        previewResult: null,
      );
      return;
    }
    String expr = state.expression;
    if (expr.isNotEmpty && '+-×÷^%'.contains(expr[expr.length - 1])) {
      expr = expr.substring(0, expr.length - 1);
    }
    final newExpr = expr + op;
    state = state.copyWith(
      expression: newExpr,
      display: _formatDisplay(newExpr),
      hasResult: false,
      previewResult: _computePreview(newExpr),
    );
  }

  void inputDecimal() {
    if (state.hasResult) {
      state = const CalculatorState(expression: '0.', display: '0.');
      return;
    }
    final parts = state.expression.split(RegExp(r'[+\-×÷()]'));
    final lastPart = parts.isEmpty ? '' : parts.last;
    if (lastPart.contains('.')) return;
    final newExpr = '${state.expression}.';
    state = state.copyWith(
      expression: newExpr,
      display: _formatDisplay(newExpr),
      previewResult: _computePreview(newExpr),
    );
  }

  void toggleSign() {
    if (state.expression.isEmpty) return;
    String expr = state.expression;
    if (expr.startsWith('-')) {
      expr = expr.substring(1);
    } else {
      expr = '-$expr';
    }
    state = state.copyWith(
      expression: expr,
      display: _formatDisplay(expr),
      previewResult: _computePreview(expr),
    );
  }

  void delete() {
    if (state.hasResult) {
      state = const CalculatorState();
      return;
    }
    if (state.expression.isEmpty) return;
    final newExpr = state.expression.substring(0, state.expression.length - 1);
    state = state.copyWith(
      expression: newExpr,
      display: newExpr.isEmpty ? '0' : _formatDisplay(newExpr),
      previewResult: newExpr.isEmpty ? null : _computePreview(newExpr),
      clearPreview: newExpr.isEmpty,
    );
  }

  void clear() {
    state = const CalculatorState();
  }

  void calculate({bool radianMode = false}) {
    _radianMode = radianMode;
    if (state.expression.isEmpty) return;
    final result = MathParser.evaluate(state.expression, radianMode: radianMode);
    if (result == null) {
      state = state.copyWith(error: 'Error', display: 'Error', hasResult: true, clearPreview: true);
      return;
    }

    final display = _formatResult(result);
    _lastExpression = state.expression;
    _lastResult = display;
    state = CalculatorState(
      expression: state.expression,
      display: display,
      hasResult: true,
      previewResult: null,
    );
  }

  void inputFromHistory(String expression) {
    state = CalculatorState(
      expression: expression,
      display: _formatDisplay(expression),
      previewResult: _computePreview(expression),
    );
  }

  // Scientific calculator functions
  void inputFunction(String fn) {
    if (state.hasResult) {
      final raw = state.display.replaceAll(',', '');
      final newExpr = '$fn($raw';
      state = CalculatorState(
        expression: newExpr,
        display: _formatDisplay(newExpr),
        previewResult: _computePreview(newExpr),
      );
      return;
    }
    final newExpr = '${state.expression}$fn(';
    state = state.copyWith(
      expression: newExpr,
      display: _formatDisplay(newExpr),
      previewResult: _computePreview(newExpr),
    );
  }

  void inputConstant(String c) {
    if (state.hasResult) {
      state = CalculatorState(
        expression: c,
        display: _formatDisplay(c),
        previewResult: null,
      );
      return;
    }
    final newExpr = state.expression + c;
    state = state.copyWith(
      expression: newExpr,
      display: _formatDisplay(newExpr),
      previewResult: _computePreview(newExpr),
    );
  }

  void inputParenthesis(String p) {
    if (state.hasResult && p == '(') {
      state = CalculatorState(expression: '(', display: '(');
      return;
    }
    final newExpr = state.expression + p;
    state = state.copyWith(
      expression: newExpr,
      display: _formatDisplay(newExpr),
      hasResult: false,
      previewResult: _computePreview(newExpr),
    );
  }

  /// Smart bracket: inserts '(' or ')' based on context.
  /// Opens a bracket when it makes sense, closes one when there are unmatched opens.
  void smartBracket() {
    if (state.hasResult) {
      state = CalculatorState(expression: '(', display: '(');
      return;
    }
    final expr = state.expression;
    final openCount = '('.allMatches(expr).length;
    final closeCount = ')'.allMatches(expr).length;
    // Insert ')' if there are unmatched '(' AND the last char is a digit or ')'
    final lastChar = expr.isEmpty ? '' : expr[expr.length - 1];
    final shouldClose = openCount > closeCount &&
        (RegExp(r'[0-9.)]').hasMatch(lastChar));
    final p = shouldClose ? ')' : '(';
    // If opening after a digit, insert implicit multiplication
    String prefix = expr;
    if (p == '(' && expr.isNotEmpty && RegExp(r'[0-9.)πe]').hasMatch(lastChar)) {
      prefix = '$expr×';
    }
    final newExpr = prefix + p;
    state = state.copyWith(
      expression: newExpr,
      display: _formatDisplay(newExpr),
      hasResult: false,
      previewResult: _computePreview(newExpr),
    );
  }
}
