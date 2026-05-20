import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/presentation/core/game_provider.dart';

import '../../generated/intl/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  IdleGame? _game;

  @override
  Widget build(BuildContext context) {
    _game ??= IdleGame(
      gameStateNotifier: ref.read(gameStateProvider.notifier),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.app_name),
      ),
      body: GameWidget(game: _game!),
    );
  }
}
