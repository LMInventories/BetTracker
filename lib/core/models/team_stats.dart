import 'fixture.dart';

class TeamMatchStats {
  final Team team;
  final int shotsOnGoal;
  final int shotsOffGoal;
  final int totalShots;
  final int blockedShots;
  final int shotsInsideBox;
  final int shotsOutsideBox;
  final int fouls;
  final int cornerKicks;
  final int offsides;
  final String? possession;
  final int yellowCards;
  final int redCards;
  final int goalkeeperSaves;
  final int totalPasses;
  final int accuratePasses;

  const TeamMatchStats({
    required this.team,
    required this.shotsOnGoal,
    required this.shotsOffGoal,
    required this.totalShots,
    required this.blockedShots,
    required this.shotsInsideBox,
    required this.shotsOutsideBox,
    required this.fouls,
    required this.cornerKicks,
    required this.offsides,
    this.possession,
    required this.yellowCards,
    required this.redCards,
    required this.goalkeeperSaves,
    required this.totalPasses,
    required this.accuratePasses,
  });

  factory TeamMatchStats.fromJson(Map<String, dynamic> json) {
    final team = Team.fromJson(json['team'] as Map<String, dynamic>);
    final stats = (json['statistics'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    int _int(String key) {
      final match = stats.firstWhere(
        (s) => s['type'] == key,
        orElse: () => {'value': null},
      );
      final v = match['value'];
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v.replaceAll('%', '')) ?? 0;
      return 0;
    }

    String? _str(String key) {
      final match = stats.firstWhere(
        (s) => s['type'] == key,
        orElse: () => {'value': null},
      );
      final v = match['value'];
      return v?.toString();
    }

    return TeamMatchStats(
      team: team,
      shotsOnGoal: _int('Shots on Goal'),
      shotsOffGoal: _int('Shots off Goal'),
      totalShots: _int('Total Shots'),
      blockedShots: _int('Blocked Shots'),
      shotsInsideBox: _int('Shots insidebox'),
      shotsOutsideBox: _int('Shots outsidebox'),
      fouls: _int('Fouls'),
      cornerKicks: _int('Corner Kicks'),
      offsides: _int('Offsides'),
      possession: _str('Ball Possession'),
      yellowCards: _int('Yellow Cards'),
      redCards: _int('Red Cards'),
      goalkeeperSaves: _int('Goalkeeper Saves'),
      totalPasses: _int('Total passes'),
      accuratePasses: _int('Passes accurate'),
    );
  }
}
