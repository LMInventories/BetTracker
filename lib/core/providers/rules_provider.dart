import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_rule.dart';

const _rulesKey = 'notification_rules';

class RulesNotifier extends StateNotifier<List<NotificationRule>> {
  RulesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_rulesKey) ?? [];
    state = raw.map(NotificationRule.fromJsonString).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _rulesKey,
      state.map((r) => r.toJsonString()).toList(),
    );
  }

  Future<void> addRule(NotificationRule rule) async {
    state = [...state, rule];
    await _save();
  }

  Future<void> removeRule(String id) async {
    state = state.where((r) => r.id != id).toList();
    await _save();
  }

  Future<void> toggleRule(String id) async {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(isActive: !r.isActive) else r,
    ];
    await _save();
  }

  Future<void> markFired(String ruleId, int fixtureId) async {
    state = [
      for (final r in state)
        if (r.id == ruleId)
          r.copyWith(firedForFixtures: {...r.firedForFixtures, fixtureId})
        else
          r,
    ];
    await _save();
  }
}

final rulesProvider =
    StateNotifierProvider<RulesNotifier, List<NotificationRule>>(
  (ref) => RulesNotifier(),
);
