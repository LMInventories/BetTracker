import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../api/football_api.dart';
import '../models/notification_rule.dart';
import '../models/player_stats.dart';
import '../models/team_stats.dart';
import 'notification_service.dart';

const _taskName = 'liveStatsPolling';
const _rulesKey = 'notification_rules';
const _firedKey = 'fired_alerts';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('rapidapi_key') ?? '';
      if (apiKey.isEmpty) return true;

      final rulesJson = prefs.getStringList(_rulesKey) ?? [];
      if (rulesJson.isEmpty) return true;

      final rules = rulesJson
          .map(NotificationRule.fromJsonString)
          .where((r) => r.isActive)
          .toList();

      await NotificationService.init();
      final api = FootballApi(apiKey);
      final liveFixtures = await api.getLiveFixtures();

      for (final fixture in liveFixtures) {
        await _checkFixture(fixture.id, rules, api, prefs);
      }

      return true;
    } catch (_) {
      return false;
    }
  });
}

Future<void> _checkFixture(
  int fixtureId,
  List<NotificationRule> rules,
  FootballApi api,
  SharedPreferences prefs,
) async {
  final firedSetKey = '$_firedKey.$fixtureId';
  final firedSet = (prefs.getStringList(firedSetKey) ?? []).toSet();

  final playerRules = rules.where((r) => r.isPlayerRule).toList();
  final teamRules = rules.where((r) => !r.isPlayerRule).toList();

  if (playerRules.isNotEmpty) {
    try {
      final players = await api.getPlayerStats(fixtureId);
      for (final rule in playerRules) {
        final firedKey = rule.id;
        if (firedSet.contains(firedKey)) continue;

        final player = players.firstWhere(
          (p) => p.playerId == rule.playerId,
          orElse: () => const PlayerMatchStats(
              playerId: 0, playerName: '', teamId: 0, isSubstitute: false),
        );
        if (player.playerId == 0) continue;

        final value = player.statValue(rule.stat);
        if (value >= rule.threshold) {
          await NotificationService.showAlert(
            title: '${rule.playerName} — ${rule.stat.label}',
            body:
                '${player.playerName} has $value ${rule.stat.label} (threshold: ${rule.threshold.toInt()}+)',
          );
          firedSet.add(firedKey);
        }
      }
    } catch (_) {}
  }

  if (teamRules.isNotEmpty) {
    try {
      final teamStats = await api.getTeamStats(fixtureId);
      for (final rule in teamRules) {
        final firedKey = rule.id;
        if (firedSet.contains(firedKey)) continue;

        final matching = teamStats.where((t) => t.team.id == rule.teamId);
        if (matching.isEmpty) continue;
        final stats = matching.first;

        final value = _teamStatValue(stats, rule.stat);
        if (value >= rule.threshold) {
          await NotificationService.showAlert(
            title: '${rule.teamName} — ${rule.stat.label}',
            body:
                '${stats.team.name} has $value ${rule.stat.label} (threshold: ${rule.threshold.toInt()}+)',
          );
          firedSet.add(firedKey);
        }
      }
    } catch (_) {}
  }

  await prefs.setStringList(firedSetKey, firedSet.toList());
}

int _teamStatValue(TeamMatchStats stats, StatType stat) {
  switch (stat) {
    case StatType.teamShotsOnTarget:
      return stats.shotsOnGoal;
    case StatType.teamShotsTotal:
      return stats.totalShots;
    case StatType.teamCorners:
    case StatType.cornersTotal:
      return stats.cornerKicks;
    case StatType.teamFouls:
      return stats.fouls;
    case StatType.teamYellowCards:
      return stats.yellowCards;
    case StatType.teamRedCards:
      return stats.redCards;
    default:
      return 0;
  }
}

class BackgroundService {
  static Future<void> register() async {
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_taskName);
  }
}
