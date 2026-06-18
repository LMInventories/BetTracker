class Fixture {
  final int id;
  final String statusShort; // NS, 1H, HT, 2H, ET, P, FT, AET, PEN
  final String statusLong;
  final int? elapsed;
  final DateTime date;
  final Team homeTeam;
  final Team awayTeam;
  final int? homeGoals;
  final int? awayGoals;
  final int? homeHT;
  final int? awayHT;
  final int leagueId;
  final String leagueName;
  final String leagueLogo;
  final String round;

  const Fixture({
    required this.id,
    required this.statusShort,
    required this.statusLong,
    this.elapsed,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals,
    this.awayGoals,
    this.homeHT,
    this.awayHT,
    required this.leagueId,
    required this.leagueName,
    required this.leagueLogo,
    required this.round,
  });

  bool get isLive => const {'1H', 'HT', '2H', 'ET', 'P', 'BT'}.contains(statusShort);
  bool get isFinished => const {'FT', 'AET', 'PEN'}.contains(statusShort);
  bool get isScheduled => statusShort == 'NS';

  factory Fixture.fromJson(Map<String, dynamic> json) {
    final fixture = json['fixture'] as Map<String, dynamic>;
    final league = json['league'] as Map<String, dynamic>;
    final teams = json['teams'] as Map<String, dynamic>;
    final goals = json['goals'] as Map<String, dynamic>? ?? {};
    final score = json['score'] as Map<String, dynamic>? ?? {};
    final ht = score['halftime'] as Map<String, dynamic>? ?? {};
    final status = fixture['status'] as Map<String, dynamic>? ?? {};

    return Fixture(
      id: fixture['id'] as int,
      statusShort: status['short'] as String? ?? 'NS',
      statusLong: status['long'] as String? ?? '',
      elapsed: status['elapsed'] as int?,
      date: DateTime.parse(fixture['date'] as String),
      homeTeam: Team.fromJson(teams['home'] as Map<String, dynamic>),
      awayTeam: Team.fromJson(teams['away'] as Map<String, dynamic>),
      homeGoals: goals['home'] as int?,
      awayGoals: goals['away'] as int?,
      homeHT: ht['home'] as int?,
      awayHT: ht['away'] as int?,
      leagueId: league['id'] as int,
      leagueName: league['name'] as String? ?? '',
      leagueLogo: league['logo'] as String? ?? '',
      round: league['round'] as String? ?? '',
    );
  }
}

class Team {
  final int id;
  final String name;
  final String logo;

  const Team({required this.id, required this.name, required this.logo});

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        logo: json['logo'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'logo': logo};
}
