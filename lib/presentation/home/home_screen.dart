import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/presentation/core/game_provider.dart';
import 'package:idle_game/presentation/home/upgrade_overlay_widget.dart';
import 'package:idle_game/utils/build_context_helper.dart';
import 'package:idle_game/utils/logger_helper.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  IdleGame? _game;
  late final Future _googleFontsPending;

  @override
  void initState() {
    appLogger.d("HomeScreenState.initState()");
    super.initState();

    GoogleFonts.vt323();
    _googleFontsPending = GoogleFonts.pendingFonts();
  }

  @override
  Widget build(BuildContext context) {
    _game ??= IdleGame(
      gameStateNotifier: ref.read(gameStateProvider.notifier),
      textTheme: Theme.of(context).textTheme,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(context.text.app_name),
      ),
      body: FutureBuilder(
        future: _googleFontsPending,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return GameWidget(
            game: _game!,
            overlayBuilderMap: {
              IdleGame.upgradeOverlay: (context, game) {
                return UpgradeOverlay(
                  game: game as IdleGame,
                  onClose: () {
                    game.dismissUpgradeOverlay();
                  },
                );
              },
            },
          );
        },
      ),
    );
  }
}
