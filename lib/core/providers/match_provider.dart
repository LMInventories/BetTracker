import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team_stats.dart';
import '../models/player_stats.dart';
import '../models/lineup.dart';
import '../models/event.dart';
import 'fixtures_provider.dart';

final matchTeamStatsProvider =
    FutureProvider.family<List<TeamMatchStats>, int>((ref, fixtureId) async {
  final api = await ref.watch(footballApiProvider.future);
  if (api == null) return [];
  return api.getTeamStats(fixtureId);
});

final matchPlayerStatsProvider =
    FutureProvider.family<List<PlayerMatchStats>, int>((ref, fixtureId) async {
  final api = await ref.watch(footballApiProvider.future);
  if (api == null) return [];
  return api.getPlayerStats(fixtureId);
});

final matchLineupsProvider =
    FutureProvider.family<List<MatchLineup>, int>((ref, fixtureId) async {
  final api = await ref.watch(footballApiProvider.future);
  if (api == null) return [];
  return api.getLineups(fixtureId);
});

final matchEventsProvider =
    FutureProvider.family<List<MatchEvent>, int>((ref, fixtureId) async {
  final api = await ref.watch(footballApiProvider.future);
  if (api == null) return [];
  return api.getEvents(fixtureId);
});
