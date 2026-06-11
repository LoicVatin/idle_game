import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/presentation/core/game_provider.dart';
import 'package:idle_game/utils/build_context_helper.dart';

class TutorialOverlay extends ConsumerStatefulWidget {
  const TutorialOverlay({super.key, required this.game, required this.onClose});

  final IdleGame game;
  final VoidCallback onClose;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TutorialOverlayState();
}

class _TutorialOverlayState extends ConsumerState<TutorialOverlay> {
  int _step = 0;
  static const int stepWelcome = 0;
  static const int stepPlayground = 1;
  static const int stepScene = 2;
  static const int stepHeader = 4;
  static const int stepWorker = 3;
  static const int stepRate = 5;
  static const int stepSwitchButtons = 6;
  static const int stepEncounterScenesButtons = 7;
  static const int stepRestSceneButton = 8;
  static const int stepUpgradeButton = 9;
  static const int stepResourcePanel = 10;
  static const int stepBottomPanel = 11;
  static const int step12 = 12;
  static const int step13 = 13;

  void _incrementCounter() {
    setState(() {
      _step++;
    });
  }

  String get _tutorialText {
    switch (_step) {
      case stepWelcome:
        return context.text.tutorial_step_welcome;
      case stepPlayground:
        return context.text.tutorial_step_playground;
      case stepScene:
        return context.text.tutorial_step_scene;
      case stepHeader:
        return context.text.tutorial_step_header;
      case stepWorker:
        return context.text.tutorial_step_worker;
      case stepRate:
        return context.text.tutorial_step_rate;
      case stepSwitchButtons:
        return context.text.tutorial_step_switch_buttons;
      case stepEncounterScenesButtons:
        return context.text.tutorial_step_encounter_scenes_buttons;
      case stepRestSceneButton:
        return context.text.tutorial_step_rest_scene_button;
      case stepUpgradeButton:
        return context.text.tutorial_step_upgrade_button;
      case stepResourcePanel:
        return context.text.tutorial_step_resource_panel;
      case stepBottomPanel:
        return context.text.tutorial_step_bottom_panel;
      case step12:
        return context.text.tutorial_step_almost;
      case step13:
        return context.text.tutorial_step_complete;
      default:
        return context.text.tutorial_step_close;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return gameState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Unable to load upgrade data: $error'),
            ),
          ),
        );
      },
      data: (data) {
        // playground and children
        final firstPlaygroundComponent = widget.game.firstPlaygroundComponent;

        Rect? highlightPlayground;
        if (firstPlaygroundComponent != null &&
            firstPlaygroundComponent.isMounted) {
          final topLeft = firstPlaygroundComponent.absoluteTopLeftPosition;
          final size = firstPlaygroundComponent.size;
          highlightPlayground = Rect.fromLTWH(
            topLeft.x,
            topLeft.y,
            size.x,
            size.y,
          );
        }

        final workerComponent = firstPlaygroundComponent?.workerComponent;
        Rect? highlightWorker;
        if (workerComponent != null && workerComponent.isMounted) {
          final topLeft = workerComponent.absoluteTopLeftPosition;
          final size = workerComponent.size;
          highlightWorker = Rect.fromLTWH(topLeft.x, topLeft.y, size.x, size.y);
        }

        final headerComponent = firstPlaygroundComponent?.headerComponent;
        Rect? highlightHeader;
        if (headerComponent != null && headerComponent.isMounted) {
          final topLeft = headerComponent.absoluteTopLeftPosition;
          final size = headerComponent.size;
          highlightHeader = Rect.fromLTWH(topLeft.x, topLeft.y, size.x, size.y);
        }

        final rateComponent = firstPlaygroundComponent?.rateComponent;
        Rect? highlightRate;
        if (rateComponent != null && rateComponent.isMounted) {
          final topLeft = rateComponent.absoluteTopLeftPosition;
          final size = rateComponent.size;
          highlightRate = Rect.fromLTWH(topLeft.x, topLeft.y, size.x, size.y);
        }

        final openUpgradePanelButtonComponent =
            firstPlaygroundComponent?.upgradeButton;
        Rect? highlightOpenUpgradePanelButton;
        if (openUpgradePanelButtonComponent != null &&
            openUpgradePanelButtonComponent.isMounted) {
          final topLeft =
              openUpgradePanelButtonComponent.absoluteTopLeftPosition;
          final size = openUpgradePanelButtonComponent.size;
          highlightOpenUpgradePanelButton = Rect.fromLTWH(
            topLeft.x,
            topLeft.y,
            size.x,
            size.y,
          );
        }

        final switchSceneComponent =
            firstPlaygroundComponent?.switchSceneComponent;
        Rect? highlightSwitchScene;
        if (switchSceneComponent != null && switchSceneComponent.isMounted) {
          final topLeft = switchSceneComponent.absoluteTopLeftPosition;
          final size = switchSceneComponent.size;
          highlightSwitchScene = Rect.fromLTWH(
            topLeft.x,
            topLeft.y,
            size.x,
            size.y,
          );
        }

        Rect? highlightSceneArea;
        if (firstPlaygroundComponent != null &&
            firstPlaygroundComponent.isMounted &&
            switchSceneComponent != null &&
            switchSceneComponent.isMounted) {
          final topLeft = firstPlaygroundComponent.absoluteTopLeftPosition;
          final size = firstPlaygroundComponent.size;
          final switchSize = switchSceneComponent.size;
          highlightSceneArea = Rect.fromLTWH(
            topLeft.x,
            topLeft.y,
            size.x - switchSize.x,
            size.y,
          );
        }

        final switchSceneButtonOneComponent =
            firstPlaygroundComponent?.switchSceneButtons.values.firstOrNull;
        Rect? highlightSwitchSceneButtonOne;
        if (switchSceneButtonOneComponent != null &&
            switchSceneButtonOneComponent.isMounted) {
          final topLeft = switchSceneButtonOneComponent.absoluteTopLeftPosition;
          final size = switchSceneButtonOneComponent.size;
          highlightSwitchSceneButtonOne = Rect.fromLTWH(
            topLeft.x,
            topLeft.y,
            size.x,
            size.y,
          );
        }

        final switchSceneButtonTwoComponent = firstPlaygroundComponent
            ?.switchSceneButtons
            .values
            .elementAtOrNull(1);
        Rect? highlightSwitchSceneButtonTwo;
        if (switchSceneButtonTwoComponent != null &&
            switchSceneButtonTwoComponent.isMounted) {
          final topLeft = switchSceneButtonTwoComponent.absoluteTopLeftPosition;
          final size = switchSceneButtonTwoComponent.size;
          highlightSwitchSceneButtonTwo = Rect.fromLTWH(
            topLeft.x,
            topLeft.y,
            size.x,
            size.y,
          );
        }

        final switchSceneButtonThreeComponent = firstPlaygroundComponent
            ?.switchSceneButtons
            .values
            .elementAtOrNull(2);
        Rect? highlightSwitchSceneButtonThree;
        if (switchSceneButtonThreeComponent != null &&
            switchSceneButtonThreeComponent.isMounted) {
          final topLeft =
              switchSceneButtonThreeComponent.absoluteTopLeftPosition;
          final size = switchSceneButtonThreeComponent.size;
          highlightSwitchSceneButtonThree = Rect.fromLTWH(
            topLeft.x,
            topLeft.y,
            size.x,
            size.y,
          );
        }
        // Resource panel
        final resourcePanelComponent = widget.game.resourcePanelComponent;

        Rect? highlightResourcePanel;
        if (resourcePanelComponent.isMounted) {
          final topLeft = resourcePanelComponent.absoluteTopLeftPosition;
          final size = resourcePanelComponent.size;
          highlightResourcePanel = Rect.fromLTWH(
            topLeft.x,
            topLeft.y,
            size.x,
            size.y,
          );
        }

        // Bottom panel
        final bottomPanelComponent = widget.game.bottomPanelComponent;

        Rect? highlightBottomPanel;
        if (bottomPanelComponent.isMounted) {
          final topLeft = bottomPanelComponent.absoluteTopLeftPosition;
          final size = bottomPanelComponent.size;
          highlightBottomPanel = Rect.fromLTWH(
            topLeft.x,
            topLeft.y,
            size.x,
            size.y,
          );
        }
        // end

        return Stack(
          children: [
            GestureDetector(
              onTap: _step >= step13 ? widget.onClose : _incrementCounter,
              child: Material(
                color: Colors.black54,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      spacing: 16,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_tutorialText, textAlign: TextAlign.center),
                        GestureDetector(
                          onTap: () {},
                          child: TextButton(
                            onPressed: widget.onClose,
                            child: Text(
                              "Skip tutorial",
                              textAlign: TextAlign.center,
                            ),
                            //icon: const Icon(Icons.close
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Playground
            if (highlightPlayground != null && _step == stepPlayground)
              Positioned.fromRect(
                rect: highlightPlayground.inflate(5),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightWorker != null && _step == stepWorker)
              Positioned.fromRect(
                rect: highlightWorker.inflate(5),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightHeader != null && _step == stepHeader)
              Positioned.fromRect(
                rect: highlightHeader.inflate(5),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightRate != null && _step == stepRate)
              Positioned.fromRect(
                rect: highlightRate.inflate(5),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightSwitchScene != null && _step == stepSwitchButtons)
              Positioned.fromRect(
                rect: highlightSwitchScene.inflate(5),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightSceneArea != null && _step == stepScene)
              Positioned.fromRect(
                rect: highlightSceneArea.inflate(5),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightSwitchSceneButtonOne != null &&
                _step == stepEncounterScenesButtons)
              Positioned.fromRect(
                rect: highlightSwitchSceneButtonOne.inflate(5),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightSwitchSceneButtonTwo != null &&
                _step == stepEncounterScenesButtons)
              Positioned.fromRect(
                rect: highlightSwitchSceneButtonTwo.inflate(5),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightSwitchSceneButtonThree != null &&
                _step == stepRestSceneButton)
              Positioned.fromRect(
                rect: highlightSwitchSceneButtonThree.inflate(5),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightOpenUpgradePanelButton != null &&
                _step == stepUpgradeButton)
              Positioned.fromRect(
                rect: highlightOpenUpgradePanelButton.inflate(5),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),

            // Resource panel
            if (highlightResourcePanel != null && _step == stepResourcePanel)
              Positioned.fromRect(
                rect: highlightResourcePanel.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),

            // Bottom panel
            if (highlightBottomPanel != null && _step == stepBottomPanel)
              Positioned.fromRect(
                rect: highlightBottomPanel.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
