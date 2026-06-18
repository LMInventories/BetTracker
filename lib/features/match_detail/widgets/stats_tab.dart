import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/match_provider.dart';
import '../../../core/models/team_stats.dart';
import '../../../core/models/player_stats.dart';

class StatsTab extends ConsumerStatefulWidget {
  final int fixtureId;
  const StatsTab({super.key, required this.fixtureId});

  @override
  ConsumerState<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<StatsTab>
    with AutomaticKeepAliveClientMixin {
  bool _showTeam = true;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        _ToggleRow(
          showTeam: _showTeam,
          onToggle: (v) => setState(() => _showTeam = v),
        ),
        Expanded(
          child:
              _showTeam ? _TeamStats(fixtureId: widget.fixtureId) : _PlayerStats(fixtureId: widget.fixtureId),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final bool showTeam;
  final ValueChanged<bool> onToggle;

  const _ToggleRow({required this.showTeam, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: true, label: Text('Team')),
          ButtonSegment(value: false, label: Text('Players')),
        ],
        selected: {showTeam},
        onSelectionChanged: (s) => onToggle(s.first),
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
    );
  }
}

// ─── Team Stats ────────────────────────────────────────────────────────────

class _TeamStats extends ConsumerWidget {
  final int fixtureId;
  const _TeamStats({required this.fixtureId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(matchTeamStatsProvider(fixtureId));
    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      data: (stats) {
        if (stats.isEmpty) {
          return const Center(
            child: Text('No stats available yet',
                style: TextStyle(color: Colors.white38)),
          );
        }
        final home = stats.first;
        final away = stats.length > 1 ? stats[1] : null;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _teamStatRows(context, home, away),
          ],
        );
      },
    );
  }

  Widget _teamStatRows(
      BuildContext context, TeamMatchStats home, TeamMatchStats? away) {
    final rows = [
      _StatEntry('Shots on Target', home.shotsOnGoal, away?.shotsOnGoal ?? 0),
      _StatEntry('Total Shots', home.totalShots, away?.totalShots ?? 0),
      _StatEntry('Shots (Inside Box)', home.shotsInsideBox, away?.shotsInsideBox ?? 0),
      _StatEntry('Corner Kicks', home.cornerKicks, away?.cornerKicks ?? 0),
      _StatEntry('Fouls', home.fouls, away?.fouls ?? 0),
      _StatEntry('Yellow Cards', home.yellowCards, away?.yellowCards ?? 0),
      _StatEntry('Red Cards', home.redCards, away?.redCards ?? 0),
      _StatEntry('Offsides', home.offsides, away?.offsides ?? 0),
      _StatEntry('GK Saves', home.goalkeeperSaves, away?.goalkeeperSaves ?? 0),
    ];

    return Column(
      children: [
        // Team header
        Row(
          children: [
            Expanded(
                child: Text(home.team.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.white),
                    textAlign: TextAlign.left)),
            Expanded(
                child: Text(away?.team.name ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.white),
                    textAlign: TextAlign.right)),
          ],
        ),
        const SizedBox(height: 16),
        ...rows.map((r) => _StatBar(entry: r)),
      ],
    );
  }
}

class _StatEntry {
  final String label;
  final int homeVal;
  final int awayVal;
  const _StatEntry(this.label, this.homeVal, this.awayVal);
}

class _StatBar extends StatelessWidget {
  final _StatEntry entry;
  const _StatBar({required this.entry});

  @override
  Widget build(BuildContext context) {
    final total = entry.homeVal + entry.awayVal;
    final homePct = total == 0 ? 0.5 : entry.homeVal / total;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Text('${entry.homeVal}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white)),
              Expanded(
                  child: Text(entry.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12))),
              Text('${entry.awayVal}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Row(
              children: [
                Expanded(
                  flex: (homePct * 100).round(),
                  child: Container(height: 4, color: primary),
                ),
                Expanded(
                  flex: ((1 - homePct) * 100).round(),
                  child: Container(
                      height: 4,
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Player Stats ──────────────────────────────────────────────────────────

class _PlayerStats extends ConsumerStatefulWidget {
  final int fixtureId;
  const _PlayerStats({required this.fixtureId});

  @override
  ConsumerState<_PlayerStats> createState() => _PlayerStatsState();
}

class _PlayerStatsState extends ConsumerState<_PlayerStats> {
  StatType _sortBy = StatType.shotsOnTarget;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(matchPlayerStatsProvider(widget.fixtureId));
    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      data: (players) {
        if (players.isEmpty) {
          return const Center(
            child: Text('Lineups not confirmed yet',
                style: TextStyle(color: Colors.white38)),
          );
        }
        final sorted = [...players]
          ..sort((a, b) =>
              b.statValue(_sortBy).compareTo(a.statValue(_sortBy)));

        return Column(
          children: [
            _SortChips(
              selected: _sortBy,
              onSelect: (s) => setState(() => _sortBy = s),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: sorted.length,
                itemBuilder: (context, i) =>
                    _PlayerRow(player: sorted[i], highlightStat: _sortBy),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SortChips extends StatelessWidget {
  final StatType selected;
  final ValueChanged<StatType> onSelect;

  static const _options = [
    StatType.shotsOnTarget,
    StatType.shotsTotal,
    StatType.goals,
    StatType.assists,
    StatType.foulsDrawn,
    StatType.foulsCommitted,
    StatType.yellowCards,
  ];

  const _SortChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        children: _options
            .map((s) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(s.label, style: const TextStyle(fontSize: 11)),
                    selected: selected == s,
                    onSelected: (_) => onSelect(s),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final PlayerMatchStats player;
  final StatType highlightStat;

  const _PlayerRow({required this.player, required this.highlightStat});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final value = player.statValue(highlightStat);

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white10,
        child: Text(
          '${player.shirtNumber ?? ''}',
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ),
      title: Text(player.playerName,
          style: const TextStyle(fontSize: 13, color: Colors.white)),
      subtitle: Text(
        '${player.position ?? ''} ${player.isSubstitute ? '(sub)' : ''}',
        style: const TextStyle(fontSize: 11, color: Colors.white38),
      ),
      trailing: value > 0
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                    color: primary, fontWeight: FontWeight.w700),
              ),
            )
          : Text('$value',
              style: const TextStyle(color: Colors.white24, fontSize: 13)),
    );
  }
}
