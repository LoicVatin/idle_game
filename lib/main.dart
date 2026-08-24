import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_game/core/styles/app_theme.dart';
import 'package:idle_game/presentation/home/home_screen.dart';
import 'package:idle_game/utils/build_context_helper.dart';
import 'package:idle_game/utils/logger_helper.dart';
import 'generated/intl/app_localizations.dart';
import 'package:flame_audio/flame_audio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.setPortrait();
  await FlameAudio.bgm.initialize();
  await FlameAudio.audioCache.loadAll(['bgm.ogg']);
  runApp(const ProviderScope(child: IdleApp()));
}

class IdleApp extends StatelessWidget {
  const IdleApp({super.key});

  @override
  Widget build(BuildContext context) {
    appLogger.d("IdleApp.build()");
    return MaterialApp(
      title: context.text.app_name,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.theme,
      home: SafeArea(top: false, child: const HomeScreen()),
    );
  }
}
