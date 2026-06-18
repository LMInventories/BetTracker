import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/notification_rule.dart';
import '../../../core/models/player_stats.dart';
import '../../../core/providers/rules_provider.dart';

class CreateRuleSheet extends ConsumerStatefulWidget {
  const CreateRuleSheet({super.key});

  @override
  ConsumerState<CreateRuleSheet> createState() => _CreateRuleSheetState();
}

class _CreateRuleSheetState extends ConsumerState<CreateRuleSheet> {
  bool _isPlayer = true;
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  StatType _stat = StatType.shotsOnTarget;
  double _threshold = 2;

  static const _playerStats = [
    StatType.shotsOnTarget,
    StatType.shotsTotal,
    StatType.goals,
    StatType.assists,
    StatType.foulsDrawn,
    StatType.foulsCommitted,
    StatType.yellowCards,
    StatType.redCards,
    StatType.saves,
    StatType.keyPasses,
  ];

  static const _teamStats = [
    StatType.teamShotsOnTarget,
    StatType.teamShotsTotal,
    StatType.teamCorners,
    StatType.teamFouls,
    StatType.teamYellowCards,
    StatType.teamRedCards,
    StatType.cornersTotal,
    StatType.cornersFirstHalf,
    StatType.cornersSecondHalf,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _isPlayer ? _playerStats : _teamStats;
    if (!stats.contains(_stat)) _stat = stats.first;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('New Alert',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),

          // Player vs Team toggle
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                  value: true,
                  icon: Icon(Icons.person),
                  label: Text('Player')),
              ButtonSegment(
                  value: false,
                  icon: Icon(Icons.shield),
                  label: Text('Team')),
            ],
            selected: {_isPlayer},
            onSelectionChanged: (s) {
              setState(() {
                _isPlayer = s.first;
                _stat = (_isPlayer ? _playerStats : _teamStats).first;
              });
            },
          ),
          const SizedBox(height: 16),

          // Name
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: _isPlayer ? 'Player name' : 'Team name',
              labelStyle: const TextStyle(color: Colors.white38),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary)),
            ),
          ),
          const SizedBox(height: 12),

          // ID (optional)
          TextField(
            controller: _idCtrl,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText:
                  _isPlayer ? 'Player ID (from API)' : 'Team ID (from API)',
              labelStyle: const TextStyle(color: Colors.white38),
              helperText: 'Optional — used for precise stat matching',
              helperStyle: const TextStyle(color: Colors.white24),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary)),
            ),
          ),
          const SizedBox(height: 16),

          // Stat picker
          const Text('Stat',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 6),
          DropdownButtonFormField<StatType>(
            value: _stat,
            dropdownColor:
                Theme.of(context).colorScheme.surfaceContainer,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24)),
            ),
            items: stats
                .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.label,
                        style: const TextStyle(color: Colors.white))))
                .toList(),
            onChanged: (v) => setState(() => _stat = v!),
          ),
          const SizedBox(height: 16),

          // Threshold slider
          Row(
            children: [
              const Text('Threshold ≥ ',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              Text(
                '${_threshold.toInt()}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ],
          ),
          Slider(
            value: _threshold,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (v) => setState(() => _threshold = v),
          ),

          // Preview label
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '"${_nameCtrl.text.isEmpty ? (_isPlayer ? 'Player' : 'Team') : _nameCtrl.text} ≥ ${_threshold.toInt()} ${_stat.label}"',
              style: const TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save Alert'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a name')),
      );
      return;
    }

    final id = const Uuid().v4();
    final parsedId = int.tryParse(_idCtrl.text.trim());

    final rule = NotificationRule(
      id: id,
      isPlayerRule: _isPlayer,
      playerId: _isPlayer ? parsedId : null,
      playerName: _isPlayer ? _nameCtrl.text.trim() : null,
      teamId: !_isPlayer ? parsedId : null,
      teamName: !_isPlayer ? _nameCtrl.text.trim() : null,
      stat: _stat,
      threshold: _threshold,
    );

    ref.read(rulesProvider.notifier).addRule(rule);
    Navigator.pop(context);
  }
}
