import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/football_api.dart';
import '../models/fixture.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final apiKeyProvider = FutureProvider<String>((ref) => ApiClient.getStoredKey());

final footballApiProvider = FutureProvider<FootballApi?>((ref) async {
  final key = await ref.watch(apiKeyProvider.future);
  if (key.isEmpty) return null;
  return FootballApi(key);
});

final fixturesByDateProvider =
    FutureProvider.family<List<Fixture>, DateTime>((ref, date) async {
  final api = await ref.watch(footballApiProvider.future);
  if (api == null) return [];
  return api.getFixturesByDate(date);
});

final liveFixturesProvider = FutureProvider<List<Fixture>>((ref) async {
  final api = await ref.watch(footballApiProvider.future);
  if (api == null) return [];
  return api.getLiveFixtures();
});

// Groups fixtures by league for display
final groupedFixturesProvider =
    FutureProvider.family<Map<String, List<Fixture>>, DateTime>(
        (ref, date) async {
  final fixtures = await ref.watch(fixturesByDateProvider(date).future);
  final map = <String, List<Fixture>>{};
  for (final f in fixtures) {
    (map[f.leagueName] ??= []).add(f);
  }
  return map;
});
