import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/match_provider.dart';
import '../../../core/models/event.dart';

class EventsTab extends ConsumerWidget {
  final int fixtureId;
  const EventsTab({super.key, required this.fixtureId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(matchEventsProvider(fixtureId));
    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: Colors.red))),
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: Text('No events yet',
                style: TextStyle(color: Colors.white38)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: events.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Colors.white10),
          itemBuilder: (context, i) => _EventTile(event: events[i]),
        );
      },
    );
  }
}

class _EventTile extends StatelessWidget {
  final MatchEvent event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconFor(event.type);
    final timeStr = event.timeExtra != null
        ? "${event.time}+${event.timeExtra}'"
        : "${event.time}'";

    return ListTile(
      dense: true,
      leading: SizedBox(
        width: 36,
        child: Text(
          timeStr,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
      ),
      title: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              event.playerName,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (event.assistName != null && event.assistName!.isNotEmpty) ...[
            const Text(' (assist: ',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
            Text(event.assistName!,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 11)),
            const Text(')',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ],
      ),
      subtitle: Text(
        '${event.teamName} · ${event.detail}',
        style: const TextStyle(color: Colors.white38, fontSize: 11),
      ),
    );
  }

  (IconData, Color) _iconFor(EventType type) {
    switch (type) {
      case EventType.goal:
        return (Icons.sports_soccer, Colors.white);
      case EventType.ownGoal:
        return (Icons.sports_soccer, Colors.red);
      case EventType.yellowCard:
        return (Icons.rectangle, Colors.yellow);
      case EventType.redCard:
        return (Icons.rectangle, Colors.red);
      case EventType.substitution:
        return (Icons.swap_horiz, Colors.blue);
      case EventType.var_:
        return (Icons.tv, Colors.purple);
      default:
        return (Icons.circle, Colors.white24);
    }
  }
}
