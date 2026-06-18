import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/rules_provider.dart';
import 'widgets/rule_card.dart';
import 'widgets/create_rule_sheet.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(rulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (rules.isNotEmpty)
            TextButton(
              onPressed: () => _showCreate(context),
              child: const Text('+ Add'),
            ),
        ],
      ),
      body: rules.isEmpty
          ? _EmptyState(onAdd: () => _showCreate(context))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => RuleCard(rule: rules[i]),
            ),
      floatingActionButton: rules.isNotEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showCreate(context),
              icon: const Icon(Icons.add),
              label: const Text('New Alert'),
            ),
    );
  }

  void _showCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateRuleSheet(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none,
                size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('No alerts set',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              'Create alerts like "Saka ≥ 2 shots on target" and get notified live.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Create alert'),
            ),
          ],
        ),
      ),
    );
  }
}
