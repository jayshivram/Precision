class HistoryEntry {
  final String id;
  final String expression;
  final String result;
  final String tab; // 'basic' or 'scientific'
  final DateTime timestamp;

  HistoryEntry({
    required this.id,
    required this.expression,
    required this.result,
    required this.tab,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'expression': expression,
    'result': result,
    'tab': tab,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    id: json['id'] as String,
    expression: json['expression'] as String,
    result: json['result'] as String,
    tab: json['tab'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
