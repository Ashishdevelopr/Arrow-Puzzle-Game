import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/audio/audio_service.dart';
import 'core/haptics/haptic_service.dart';
import 'core/storage/progress_store.dart';
import 'game/state/game_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load persisted user prefs before the widget tree builds
  final store = await ProgressStore.load();

  runApp(
    ProviderScope(
      overrides: [
        // Seed haptic + audio services with stored user prefs at launch
        hapticServiceProvider.overrideWith((ref) {
          final svc = HapticService();
          svc.setEnabled(store.hapticsEnabled);
          return svc;
        }),
        audioServiceProvider.overrideWith((ref) {
          final svc = AudioService();
          svc.setSoundEnabled(store.soundEnabled);
          return svc;
        }),
      ],
      child: const ArrowPuzzleApp(),
    ),
  );
}
