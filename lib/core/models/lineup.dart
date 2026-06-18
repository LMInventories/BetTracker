import 'fixture.dart';

class MatchLineup {
  final Team team;
  final String formation;
  final List<LineupPlayer> startingXI;
  final List<LineupPlayer> substitutes;
  final Coach? coach;

  const MatchLineup({
    required this.team,
    required this.formation,
    required this.startingXI,
    required this.substitutes,
    this.coach,
  });

  factory MatchLineup.fromJson(Map<String, dynamic> json) {
    final team = Team.fromJson(json['team'] as Map<String, dynamic>);

    List<LineupPlayer> parsePlayers(String key) {
      return ((json[key] as List<dynamic>?) ?? [])
          .cast<Map<String, dynamic>>()
          .map((p) => LineupPlayer.fromJson(p, team.id))
          .toList();
    }

    Coach? coach;
    if (json['coach'] != null) {
      coach = Coach.fromJson(json['coach'] as Map<String, dynamic>);
    }

    return MatchLineup(
      team: team,
      formation: json['formation'] as String? ?? '',
      startingXI: parsePlayers('startXI'),
      substitutes: parsePlayers('substitutes'),
      coach: coach,
    );
  }
}

class LineupPlayer {
  final int id;
  final String name;
  final int number;
  final String position;
  final String? photo;
  final int teamId;
  final String? gridPosition;

  const LineupPlayer({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    this.photo,
    required this.teamId,
    this.gridPosition,
  });

  factory LineupPlayer.fromJson(Map<String, dynamic> json, int teamId) {
    final player = json['player'] as Map<String, dynamic>? ?? {};
    return LineupPlayer(
      id: player['id'] as int? ?? 0,
      name: player['name'] as String? ?? '',
      number: player['number'] as int? ?? 0,
      position: player['pos'] as String? ?? '',
      photo: player['photo'] as String?,
      teamId: teamId,
      gridPosition: player['grid'] as String?,
    );
  }
}

class Coach {
  final int id;
  final String name;
  final String? photo;

  const Coach({required this.id, required this.name, this.photo});

  factory Coach.fromJson(Map<String, dynamic> json) => Coach(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        photo: json['photo'] as String?,
      );
}
