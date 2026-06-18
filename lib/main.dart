import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationService.init();
    await NotificationService.requestPermission();
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }

  try {
    await Workmanager().initialize(callbackDispatcher);
    await BackgroundService.register();
  } catch (e) {
    debugPrint('Workmanager init error: $e');
  }

  runApp(const ProviderScope(child: BetTrackerApp()));
}
