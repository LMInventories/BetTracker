import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/match_provider.dart';
import '../../../core/models/lineup.dart';

class LineupTab extends ConsumerWidget {
  final int fixtureId;
  const LineupTab({super.key, required this.fixtureId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineupsAsync = ref.watch(matchLineupsProvider(fixtureId));
    return lineupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: Colors.red))),
      data: (lineups) {
        if (lineups.isEmpty) {
          return const Center(
            child: Text('Lineups not yet announced',
                style: TextStyle(color: Colors.white38)),
          );
        }
        final home = lineups.first;
        final away = lineups.length > 1 ? lineups[1] : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LineupSection(lineup: home, isHome: true),
              const Divider(height: 32, color: Colors.white12),
              if (away != null) _LineupSection(lineup: away, isHome: false),
            ],
          ),
        );
      },
    );
  }
}

class _LineupSection extends StatelessWidget {
  final MatchLineup lineup;
  final bool isHome;

  const _LineupSection({required this.lineup, required this.isHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              lineup.team.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                lineup.formation,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Starting XI',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        ...lineup.startingXI.map((p) => _PlayerTile(player: p)),
        const SizedBox(height: 12),
        const Text('Substitutes',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        ...lineup.substitutes.map((p) => _PlayerTile(player: p, isSub: true)),
        if (lineup.coach != null) ...[
          const SizedBox(height: 12),
          const Text('Manager',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person, color: Colors.white24),
            title: Text(lineup.coach!.name,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ],
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final LineupPlayer player;
  final bool isSub;

  const _PlayerTile({required this.player, this.isSub = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: isSub ? Colors.white10 : Colors.white12,
        child: Text(
          '${player.number}',
          style: TextStyle(
              fontSize: 11,
              color: isSub ? Colors.white38 : Colors.white70,
              fontWeight: FontWeight.w600),
        ),
      ),
      title: Text(
        player.name,
        style: TextStyle(
            fontSize: 13,
            color: isSub ? Colors.white54 : Colors.white,
            fontWeight: isSub ? FontWeight.w400 : FontWeight.w500),
      ),
      trailing: Text(
        _posLabel(player.position),
        style: const TextStyle(color: Colors.white24, fontSize: 11),
      ),
    );
  }

  String _posLabel(String pos) {
    switch (pos) {
      case 'G':
        return 'GK';
      case 'D':
        return 'DEF';
      case 'M':
        return 'MID';
      case 'F':
        return 'FWD';
      default:
        return pos;
    }
  }
}
