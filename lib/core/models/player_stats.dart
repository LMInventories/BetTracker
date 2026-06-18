class PlayerMatchStats {
  final int playerId;
  final String playerName;
  final String? photo;
  final int teamId;
  final int? minutesPlayed;
  final int? shirtNumber;
  final String? position;
  final bool isSubstitute;
  final int? shotsTotal;
  final int? shotsOnTarget;
  final int? goalsScored;
  final int? assists;
  final int? foulsCommitted;
  final int? foulsDrawn;
  final int? yellowCards;
  final int? redCards;
  final int? dribblesAttempted;
  final int? dribblesSucceeded;
  final int? keyPasses;
  final int? saves;

  const PlayerMatchStats({
    required this.playerId,
    required this.playerName,
    this.photo,
    required this.teamId,
    this.minutesPlayed,
    this.shirtNumber,
    this.position,
    required this.isSubstitute,
    this.shotsTotal,
    this.shotsOnTarget,
    this.goalsScored,
    this.assists,
    this.foulsCommitted,
    this.foulsDrawn,
    this.yellowCards,
    this.redCards,
    this.dribblesAttempted,
    this.dribblesSucceeded,
    this.keyPasses,
    this.saves,
  });

  int statValue(StatType stat) {
    switch (stat) {
      case StatType.shotsOnTarget:
        return shotsOnTarget ?? 0;
      case StatType.shotsTotal:
        return shotsTotal ?? 0;
      case StatType.goals:
        return goalsScored ?? 0;
      case StatType.assists:
        return assists ?? 0;
      case StatType.foulsCommitted:
        return foulsCommitted ?? 0;
      case StatType.foulsDrawn:
        return foulsDrawn ?? 0;
      case StatType.yellowCards:
        return yellowCards ?? 0;
      case StatType.redCards:
        return redCards ?? 0;
      case StatType.keyPasses:
        return keyPasses ?? 0;
      case StatType.saves:
        return saves ?? 0;
      default:
        return 0;
    }
  }

  factory PlayerMatchStats.fromApiJson(
      Map<String, dynamic> playerJson, int teamId) {
    final player = playerJson['player'] as Map<String, dynamic>;
    final statsList =
        (playerJson['statistics'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final s = statsList.isNotEmpty ? statsList.first : <String, dynamic>{};

    int? _int(Map<String, dynamic>? map, String key) {
      if (map == null) return null;
      final v = map[key];
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    final games = s['games'] as Map<String, dynamic>?;
    final shots = s['shots'] as Map<String, dynamic>?;
    final goals = s['goals'] as Map<String, dynamic>?;
    final passes = s['passes'] as Map<String, dynamic>?;
    final fouls = s['fouls'] as Map<String, dynamic>?;
    final cards = s['cards'] as Map<String, dynamic>?;
    final dribbles = s['dribbles'] as Map<String, dynamic>?;

    return PlayerMatchStats(
      playerId: player['id'] as int,
      playerName: player['name'] as String? ?? '',
      photo: player['photo'] as String?,
      teamId: teamId,
      minutesPlayed: _int(games, 'minutes'),
      shirtNumber: _int(games, 'number'),
      position: games?['position'] as String?,
      isSubstitute: games?['substitute'] as bool? ?? false,
      shotsTotal: _int(shots, 'total'),
      shotsOnTarget: _int(shots, 'on'),
      goalsScored: _int(goals, 'total'),
      assists: _int(goals, 'assists'),
      foulsCommitted: _int(fouls, 'committed'),
      foulsDrawn: _int(fouls, 'drawn'),
      yellowCards: _int(cards, 'yellow'),
      redCards: _int(cards, 'red'),
      dribblesAttempted: _int(dribbles, 'attempts'),
      dribblesSucceeded: _int(dribbles, 'success'),
      keyPasses: _int(passes, 'key'),
      saves: _int(goals, 'saves'),
    );
  }
}

enum StatType {
  shotsOnTarget,
  shotsTotal,
  goals,
  assists,
  foulsCommitted,
  foulsDrawn,
  yellowCards,
  redCards,
  keyPasses,
  saves,
  cornersTotal,
  cornersFirstHalf,
  cornersSecondHalf,
  teamShotsOnTarget,
  teamShotsTotal,
  teamCorners,
  teamFouls,
  teamYellowCards,
  teamRedCards,
}

extension StatTypeLabel on StatType {
  String get label {
    switch (this) {
      case StatType.shotsOnTarget:
        return 'Shots on Target';
      case StatType.shotsTotal:
        return 'Total Shots';
      case StatType.goals:
        return 'Goals';
      case StatType.assists:
        return 'Assists';
      case StatType.foulsCommitted:
        return 'Fouls Committed';
      case StatType.foulsDrawn:
        return 'Fouls Drawn';
      case StatType.yellowCards:
        return 'Yellow Cards';
      case StatType.redCards:
        return 'Red Cards';
      case StatType.keyPasses:
        return 'Key Passes';
      case StatType.saves:
        return 'Saves';
      case StatType.cornersTotal:
        return 'Corners (Total)';
      case StatType.cornersFirstHalf:
        return 'Corners (1st Half)';
      case StatType.cornersSecondHalf:
        return 'Corners (2nd Half)';
      case StatType.teamShotsOnTarget:
        return 'Team Shots on Target';
      case StatType.teamShotsTotal:
        return 'Team Total Shots';
      case StatType.teamCorners:
        return 'Team Corners';
      case StatType.teamFouls:
        return 'Team Fouls';
      case StatType.teamYellowCards:
        return 'Team Yellow Cards';
      case StatType.teamRedCards:
        return 'Team Red Cards';
    }
  }

  bool get isTeamStat => const {
        StatType.cornersTotal,
        StatType.cornersFirstHalf,
        StatType.cornersSecondHalf,
        StatType.teamShotsOnTarget,
        StatType.teamShotsTotal,
        StatType.teamCorners,
        StatType.teamFouls,
        StatType.teamYellowCards,
        StatType.teamRedCards,
      }.contains(this);
}
