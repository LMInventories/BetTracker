import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/models/fixture.dart';

class FixtureCard extends StatelessWidget {
  final Fixture fixture;
  const FixtureCard({super.key, required this.fixture});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/match/${fixture.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _StatusBadge(fixture: fixture),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _TeamRow(
                        team: fixture.homeTeam,
                        goals: fixture.homeGoals,
                        isWinner: (fixture.homeGoals ?? 0) >
                            (fixture.awayGoals ?? 0)),
                    const SizedBox(height: 6),
                    _TeamRow(
                        team: fixture.awayTeam,
                        goals: fixture.awayGoals,
                        isWinner: (fixture.awayGoals ?? 0) >
                            (fixture.homeGoals ?? 0)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: Colors.white24, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final Team team;
  final int? goals;
  final bool isWinner;

  const _TeamRow(
      {required this.team, required this.goals, required this.isWinner});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CachedNetworkImage(
          imageUrl: team.logo,
          width: 22,
          height: 22,
          errorWidget: (_, __, ___) =>
              const Icon(Icons.sports_soccer, size: 22, color: Colors.white24),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            team.name,
            style: TextStyle(
              fontWeight:
                  isWinner ? FontWeight.w700 : FontWeight.w400,
              color: isWinner ? Colors.white : Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        if (goals != null)
          Text(
            '$goals',
            style: TextStyle(
              fontWeight:
                  isWinner ? FontWeight.w700 : FontWeight.w500,
              color: isWinner ? Colors.white : Colors.white60,
              fontSize: 15,
            ),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Fixture fixture;
  const _StatusBadge({required this.fixture});

  @override
  Widget build(BuildContext context) {
    if (fixture.isLive) {
      return Column(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: Text(
              fixture.statusShort,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "${fixture.elapsed}'",
            style: const TextStyle(
                color: Colors.red, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }
    if (fixture.isFinished) {
      return const SizedBox(
        width: 48,
        child: Text(
          'FT',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      );
    }
    // Scheduled
    final time = DateFormat('HH:mm').format(fixture.date.toLocal());
    return SizedBox(
      width: 48,
      child: Text(
        time,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}
