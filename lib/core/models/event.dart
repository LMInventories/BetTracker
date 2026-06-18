class MatchEvent {
  final int time;
  final int? timeExtra;
  final int teamId;
  final String teamName;
  final String teamLogo;
  final int? playerId;
  final String playerName;
  final int? assistId;
  final String? assistName;
  final EventType type;
  final String detail;

  const MatchEvent({
    required this.time,
    this.timeExtra,
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    this.playerId,
    required this.playerName,
    this.assistId,
    this.assistName,
    required this.type,
    required this.detail,
  });

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    final timeMap = json['time'] as Map<String, dynamic>? ?? {};
    final team = json['team'] as Map<String, dynamic>? ?? {};
    final player = json['player'] as Map<String, dynamic>? ?? {};
    final assist = json['assist'] as Map<String, dynamic>? ?? {};

    final typeStr = json['type'] as String? ?? '';
    final detail = json['detail'] as String? ?? '';

    EventType type;
    switch (typeStr) {
      case 'Goal':
        type = detail.toLowerCase().contains('own')
            ? EventType.ownGoal
            : EventType.goal;
      case 'Card':
        type = detail.toLowerCase().contains('red')
            ? EventType.redCard
            : EventType.yellowCard;
      case 'subst':
        type = EventType.substitution;
      case 'Var':
        type = EventType.var_;
      default:
        type = EventType.other;
    }

    return MatchEvent(
      time: timeMap['elapsed'] as int? ?? 0,
      timeExtra: timeMap['extra'] as int?,
      teamId: team['id'] as int? ?? 0,
      teamName: team['name'] as String? ?? '',
      teamLogo: team['logo'] as String? ?? '',
      playerId: player['id'] as int?,
      playerName: player['name'] as String? ?? '',
      assistId: assist['id'] as int?,
      assistName: assist['name'] as String?,
      type: type,
      detail: detail,
    );
  }
}

enum EventType { goal, ownGoal, yellowCard, redCard, substitution, var_, other }
