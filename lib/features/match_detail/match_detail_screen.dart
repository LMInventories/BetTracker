import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/fixtures_provider.dart';
import '../../core/providers/match_provider.dart';
import '../../core/models/fixture.dart';
import 'widgets/stats_tab.dart';
import 'widgets/lineup_tab.dart';
import 'widgets/events_tab.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final int fixtureId;
  const MatchDetailScreen({super.key, required this.fixtureId});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    // Auto-refresh every 60s when viewing a live match
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!mounted) return;
      ref.invalidate(matchTeamStatsProvider(widget.fixtureId));
      ref.invalidate(matchPlayerStatsProvider(widget.fixtureId));
      ref.invalidate(matchEventsProvider(widget.fixtureId));
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fixturesAsync =
        ref.watch(fixturesByDateProvider(DateTime.now()));

    // Find the fixture from cached data or fall back to a minimal header
    Fixture? fixture;
    fixturesAsync.whenData((list) {
      try {
        fixture = list.firstWhere((f) => f.id == widget.fixtureId);
      } catch (_) {}
    });

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: fixture != null
            ? Text(fixture!.leagueName,
                style: const TextStyle(fontSize: 14, color: Colors.white54))
            : const Text('Match'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Stats'),
            Tab(text: 'Lineups'),
            Tab(text: 'Events'),
          ],
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.white54,
        ),
      ),
      body: Column(
        children: [
          if (fixture != null) _ScoreHeader(fixture: fixture!),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                StatsTab(fixtureId: widget.fixtureId),
                LineupTab(fixtureId: widget.fixtureId),
                EventsTab(fixtureId: widget.fixtureId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  final Fixture fixture;
  const _ScoreHeader({required this.fixture});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _TeamCol(team: fixture.homeTeam)),
          Column(
            children: [
              if (fixture.isLive || fixture.isFinished)
                Text(
                  '${fixture.homeGoals ?? 0}  –  ${fixture.awayGoals ?? 0}',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                )
              else
                const Text('vs',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 18,
                        fontWeight: FontWeight.w300)),
              const SizedBox(height: 4),
              if (fixture.isLive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text("${fixture.elapsed}'",
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                )
              else if (fixture.isFinished)
                const Text('Full Time',
                    style: TextStyle(color: Colors.white38, fontSize: 12))
              else
                Text(
                  _formatKO(fixture.date),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              if (fixture.homeHT != null && fixture.awayHT != null)
                Text(
                  'HT: ${fixture.homeHT} – ${fixture.awayHT}',
                  style: const TextStyle(color: Colors.white24, fontSize: 11),
                ),
            ],
          ),
          Expanded(child: _TeamCol(team: fixture.awayTeam, isAway: true)),
        ],
      ),
    );
  }

  String _formatKO(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _TeamCol extends StatelessWidget {
  final Team team;
  final bool isAway;
  const _TeamCol({required this.team, this.isAway = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CachedNetworkImage(
          imageUrl: team.logo,
          width: 48,
          height: 48,
          errorWidget: (_, __, ___) =>
              const Icon(Icons.sports_soccer, size: 48, color: Colors.white24),
        ),
        const SizedBox(height: 6),
        Text(
          team.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
