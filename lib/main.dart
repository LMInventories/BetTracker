import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await NotificationService.requestPermission();

  await Workmanager().initialize(callbackDispatcher);
  await BackgroundService.register();

  runApp(const ProviderScope(child: BetTrackerApp()));
}
