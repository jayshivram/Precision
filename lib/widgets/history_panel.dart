import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/history_provider.dart';
import '../providers/calculator_provider.dart';
import '../theme/app_theme.dart';

class HistoryPanel extends ConsumerWidget {
  const HistoryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HISTORY',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  if (history.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.surfaceContainerLow,
                            title: const Text('Clear History'),
                            content: const Text('Remove all history entries?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(historyProvider.notifier).clearAll();
                                  Navigator.pop(ctx);
                                },
                                child: Text('Clear', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'CLEAR',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Text(
                        'No calculations yet',
                        style: GoogleFonts.inter(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return Dismissible(
                          key: Key(entry.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            ref.read(historyProvider.notifier).removeEntry(entry.id);
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: AppColors.error.withValues(alpha: 0.2),
                            child: Icon(Icons.delete, color: AppColors.error),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              ref.read(calculatorProvider.notifier).inputFromHistory(entry.expression);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.surfaceContainerLow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    entry.expression,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '= ${entry.result}',
                                    style: GoogleFonts.manrope(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(entry.timestamp),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
