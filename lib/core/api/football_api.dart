import 'package:dio/dio.dart';
import '../models/fixture.dart';
import '../models/team_stats.dart';
import '../models/player_stats.dart';
import '../models/lineup.dart';
import '../models/event.dart';
import 'api_client.dart';

class FootballApi {
  final Dio _dio;

  FootballApi(String apiKey) : _dio = ApiClient.create(apiKey);

  Future<List<Fixture>> getFixturesByDate(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await _dio.get<Map<String, dynamic>>('/fixtures', queryParameters: {'date': dateStr});
    return _parseFixtures(response.data!);
  }

  Future<List<Fixture>> getLiveFixtures() async {
    final response = await _dio.get<Map<String, dynamic>>('/fixtures', queryParameters: {'live': 'all'});
    return _parseFixtures(response.data!);
  }

  Future<List<TeamMatchStats>> getTeamStats(int fixtureId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/fixtures/statistics',
      queryParameters: {'fixture': fixtureId},
    );
    final list = (response.data!['response'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return list.map(TeamMatchStats.fromJson).toList();
  }

  Future<List<PlayerMatchStats>> getPlayerStats(int fixtureId) async {
    final List<PlayerMatchStats> allPlayers = [];

    // API returns per-team pages; fetch both teams
    final response = await _dio.get<Map<String, dynamic>>(
      '/fixtures/players',
      queryParameters: {'fixture': fixtureId},
    );
    final teams = (response.data!['response'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    for (final teamData in teams) {
      final teamId = (teamData['team'] as Map<String, dynamic>)['id'] as int;
      final players = (teamData['players'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      for (final p in players) {
        allPlayers.add(PlayerMatchStats.fromApiJson(p, teamId));
      }
    }

    return allPlayers;
  }

  Future<List<MatchLineup>> getLineups(int fixtureId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/fixtures/lineups',
      queryParameters: {'fixture': fixtureId},
    );
    final list = (response.data!['response'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return list.map(MatchLineup.fromJson).toList();
  }

  Future<List<MatchEvent>> getEvents(int fixtureId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/fixtures/events',
      queryParameters: {'fixture': fixtureId},
    );
    final list = (response.data!['response'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return list.map(MatchEvent.fromJson).toList();
  }

  List<Fixture> _parseFixtures(Map<String, dynamic> data) {
    final list = (data['response'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return list.map(Fixture.fromJson).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
