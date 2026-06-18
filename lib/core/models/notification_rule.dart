import 'dart:convert';
import 'player_stats.dart';

class NotificationRule {
  final String id;
  final bool isPlayerRule; // false = team rule
  final int? playerId;
  final String? playerName;
  final int? teamId;
  final String? teamName;
  final int? fixtureId; // null = applies to all upcoming/live fixtures
  final StatType stat;
  final double threshold;
  final bool isActive;
  // Tracks fixture IDs where this rule has already fired (prevents spam)
  final Set<int> firedForFixtures;

  const NotificationRule({
    required this.id,
    required this.isPlayerRule,
    this.playerId,
    this.playerName,
    this.teamId,
    this.teamName,
    this.fixtureId,
    required this.stat,
    required this.threshold,
    this.isActive = true,
    this.firedForFixtures = const {},
  });

  String get displayLabel {
    final target = isPlayerRule ? playerName : teamName;
    final op = '≥ ${threshold.toInt()}';
    return '$target $op ${stat.label}';
  }

  bool shouldFire(int currentValue, int forFixtureId) {
    if (!isActive) return false;
    if (firedForFixtures.contains(forFixtureId)) return false;
    return currentValue >= threshold;
  }

  NotificationRule copyWith({
    bool? isActive,
    Set<int>? firedForFixtures,
  }) =>
      NotificationRule(
        id: id,
        isPlayerRule: isPlayerRule,
        playerId: playerId,
        playerName: playerName,
        teamId: teamId,
        teamName: teamName,
        fixtureId: fixtureId,
        stat: stat,
        threshold: threshold,
        isActive: isActive ?? this.isActive,
        firedForFixtures: firedForFixtures ?? this.firedForFixtures,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isPlayerRule': isPlayerRule,
        'playerId': playerId,
        'playerName': playerName,
        'teamId': teamId,
        'teamName': teamName,
        'fixtureId': fixtureId,
        'stat': stat.name,
        'threshold': threshold,
        'isActive': isActive,
        'firedForFixtures': firedForFixtures.toList(),
      };

  factory NotificationRule.fromJson(Map<String, dynamic> json) {
    final firedList = (json['firedForFixtures'] as List<dynamic>? ?? [])
        .map((e) => e as int)
        .toSet();
    return NotificationRule(
      id: json['id'] as String,
      isPlayerRule: json['isPlayerRule'] as bool? ?? true,
      playerId: json['playerId'] as int?,
      playerName: json['playerName'] as String?,
      teamId: json['teamId'] as int?,
      teamName: json['teamName'] as String?,
      fixtureId: json['fixtureId'] as int?,
      stat: StatType.values.firstWhere(
        (e) => e.name == json['stat'],
        orElse: () => StatType.shotsOnTarget,
      ),
      threshold: (json['threshold'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      firedForFixtures: firedList,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  static NotificationRule fromJsonString(String s) =>
      NotificationRule.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
