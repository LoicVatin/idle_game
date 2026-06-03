import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_game/presentation/home/home_screen.dart';
import 'generated/intl/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: IdleApp()));
}

class IdleApp extends StatelessWidget {
  const IdleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Idle Game",
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafeArea(top: false, child: const HomeScreen()),
    );
  }
}
