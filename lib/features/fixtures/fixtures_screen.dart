import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/fixture.dart';
import '../../core/providers/fixtures_provider.dart';
import 'widgets/fixture_card.dart';
import 'widgets/date_filter_bar.dart';

class FixturesScreen extends ConsumerWidget {
  const FixturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final groupedAsync = ref.watch(groupedFixturesProvider(selectedDate));
    final apiKeyAsync = ref.watch(apiKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BetTracker', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          // Live indicator
          ref.watch(liveFixturesProvider).when(
                data: (live) => live.isEmpty
                    ? const SizedBox.shrink()
                    : Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            Text('${live.length} LIVE',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
        ],
      ),
      body: apiKeyAsync.when(
        data: (key) {
          if (key.isEmpty) {
            return _NoApiKey();
          }
          return Column(
            children: [
              DateFilterBar(selectedDate: selectedDate),
              Expanded(
                child: groupedAsync.when(
                  data: (grouped) {
                    if (grouped.isEmpty) {
                      return const Center(
                        child: Text('No matches found for this date',
                            style: TextStyle(color: Colors.white54)),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(groupedFixturesProvider(selectedDate));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: grouped.length,
                        itemBuilder: (context, i) {
                          final league = grouped.keys.elementAt(i);
                          final fixtures = grouped[league]!;
                          return _LeagueSection(
                              league: league, fixtures: fixtures);
                        },
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 40),
                        const SizedBox(height: 12),
                        Text('$e',
                            style: const TextStyle(color: Colors.white54),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => ref.invalidate(
                              groupedFixturesProvider(selectedDate)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _LeagueSection extends StatelessWidget {
  final String league;
  final List<Fixture> fixtures;

  const _LeagueSection({required this.league, required this.fixtures});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            league,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5),
          ),
        ),
        ...fixtures.map((f) => FixtureCard(fixture: f)),
      ],
    );
  }
}

class _NoApiKey extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.key, size: 56, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'No API key set',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your RapidAPI key in Settings to start tracking matches.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
