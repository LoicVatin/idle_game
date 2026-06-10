import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/presentation/core/game_provider.dart';

class TutorialOverlay extends ConsumerWidget {
  const TutorialOverlay({super.key, required this.game, required this.onClose});

  final IdleGame game;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        final firstPlaygroundComponent = game.firstPlaygroundComponent;

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
        // Resource panel
        final resourcePanelComponent = game.resourcePanelComponent;

        Rect? highlightResourcePanel;
        if (resourcePanelComponent != null &&
            resourcePanelComponent.isMounted) {
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
        final bottomPanelComponent = game.bottomPanelComponent;

        Rect? highlightBottomPanel;
        if (bottomPanelComponent != null &&
            bottomPanelComponent.isMounted) {
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
              onTap: onClose,
              child: Material(
                color: Colors.black54,
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Playground
            if (highlightPlayground != null)
              Positioned.fromRect(
                rect: highlightPlayground.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightWorker != null)
              Positioned.fromRect(
                rect: highlightWorker.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightHeader != null)
              Positioned.fromRect(
                rect: highlightHeader.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightRate != null)
              Positioned.fromRect(
                rect: highlightRate.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightSwitchScene != null)
              Positioned.fromRect(
                rect: highlightSwitchScene.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightSwitchSceneButtonOne != null)
              Positioned.fromRect(
                rect: highlightSwitchSceneButtonOne.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightSwitchSceneButtonTwo != null)
              Positioned.fromRect(
                rect: highlightSwitchSceneButtonTwo.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purpleAccent, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightSwitchSceneButtonThree != null)
              Positioned.fromRect(
                rect: highlightSwitchSceneButtonThree.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange, width: 3),
                    ),
                  ),
                ),
              ),
            if (highlightOpenUpgradePanelButton != null)
              Positioned.fromRect(
                rect: highlightOpenUpgradePanelButton.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 3),
                    ),
                  ),
                ),
              ),

            // Resource panel
            if (highlightResourcePanel != null)
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
            if (highlightBottomPanel != null)
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
