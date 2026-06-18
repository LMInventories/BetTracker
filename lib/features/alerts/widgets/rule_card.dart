import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_rule.dart';
import '../../../core/providers/rules_provider.dart';

class RuleCard extends ConsumerWidget {
  final NotificationRule rule;
  const RuleCard({super.key, required this.rule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(
              rule.isPlayerRule ? Icons.person : Icons.shield,
              color: rule.isActive ? primary : Colors.white24,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.displayLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: rule.isActive ? Colors.white : Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rule.stat.label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: rule.isActive,
              activeColor: primary,
              onChanged: (_) =>
                  ref.read(rulesProvider.notifier).toggleRule(rule.id),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.white24, size: 20),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete alert?'),
        content: Text('Remove "${rule.displayLabel}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(rulesProvider.notifier).removeRule(rule.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
