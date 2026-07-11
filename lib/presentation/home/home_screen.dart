import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/presentation/core/game_provider.dart';
import 'package:idle_game/presentation/home/tutorial_overlay_widget.dart';
import 'package:idle_game/presentation/home/upgrade_overlay_widget.dart';
import 'package:idle_game/utils/build_context_helper.dart';
import 'package:idle_game/utils/logger_helper.dart';
import 'package:idle_game/utils/shared_preferences_helper.dart';
import 'package:idle_game/core/styles/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  IdleGame? _game;
  late final Future _googleFontsPending;
  bool _isTutorialAtStartupDismissed = false;
  bool _ignoreNextMainPop = false;

  @override
  void initState() {
    appLogger.d("HomeScreenState.initState()");
    super.initState();

    isTutorialAtStartupDismissed();

    GoogleFonts.vt323();
    _googleFontsPending = GoogleFonts.pendingFonts();
  }

  @override
  Widget build(BuildContext context) {
    _game ??= IdleGame(
      gameStateNotifier: ref.read(gameStateProvider.notifier),
      textTheme: Theme.of(context).textTheme,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        if (_ignoreNextMainPop) {
          _ignoreNextMainPop = false;
          return;
        }

        final shouldLeave = await _showLeaveAppDialog(context);
        if (shouldLeave) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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

            final gameWidget = GameWidget(
              game: _game!,
              overlayBuilderMap: {
                IdleGame.tutorialOverlay: (context, game) {
                  return TutorialOverlay(
                    game: game as IdleGame,
                    onClose: () {
                      game.dismissTutorialOverlay();
                      dismissTutorialAtStartup();
                    },
                  );
                },
                IdleGame.upgradeOverlay: (context, game) {
                  _ignoreNextMainPop = true;
                  return UpgradeOverlay(
                    game: game as IdleGame,
                    onClose: () {
                      _ignoreNextMainPop = false;
                      game.dismissUpgradeOverlay();
                    },
                  );
                },
              },
              initialActiveOverlays: _isTutorialAtStartupDismissed
                  ? []
                  : [IdleGame.tutorialOverlay],
            );

            if (context.isWebMobile) {
              if (context.isLandscape) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      context.text.device_orientation_warning,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                );
              }

              return gameWidget;
            }

            if (context.isWebDesktop) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image.asset('images/web_background.png').image,
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.none,
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: gameWidget,
                  ),
                ),
              );
            }
            return gameWidget;
          },
        ),
      ),
    );
  }

  Future<void> isTutorialAtStartupDismissed() async {
    final isTutorialAtStartupDismissed =
        await SharedPreferencesHelper.isTutorialAtStartupDismissed();
    setState(() {
      _isTutorialAtStartupDismissed = isTutorialAtStartupDismissed;
    });
  }

  Future<bool> _showLeaveAppDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierColor: AppColors.dark.withValues(alpha: 0.5),
          builder: (context) {
            return Dialog(
              backgroundColor: AppColors.dark,
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: AppColors.light, width: 4),
                borderRadius: BorderRadius.zero,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.dark,
                  border: Border.all(color: AppColors.light, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 24,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.text.quit_game_dialog_title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(context.text.quit_game_dialog_body),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 12,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(context.text.cancel_button),
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(context.text.confirm_button),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  Future<void> dismissTutorialAtStartup() async {
    SharedPreferencesHelper.dismissTutorial();
  }
}
