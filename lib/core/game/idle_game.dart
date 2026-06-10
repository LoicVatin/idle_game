import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/bottom_panel_component.dart';
import 'package:idle_game/core/game/components/resource_panel_component.dart';
import 'package:idle_game/core/game/components/scrollable_component_list.dart';
import 'package:idle_game/presentation/core/game_provider.dart';
import 'package:idle_game/utils/logger_helper.dart';

import 'components/playground_component.dart';

class IdleGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final GameStateNotifier gameStateNotifier;
  final TextTheme textTheme;

  IdleGame({required this.gameStateNotifier, required this.textTheme});

  late final ResourcePanelComponent resourcePanelComponent;
  late final ScrollableComponentList _playgroundList;
  late final BottomPanelComponent bottomPanelComponent;

  static const String upgradeOverlay = 'upgrade_overlay';
  static const String tutorialOverlay = 'tutorial_overlay';
  int? upgradeOverlayPlaygroundId;

  PlaygroundComponent? get firstPlaygroundComponent => children
      .whereType<ScrollableComponentList>()
      .firstOrNull
      ?.children
      .whereType<PlaygroundComponent>()
      .firstOrNull;

  @override
  Color backgroundColor() => Colors.indigo;

  @override
  Future<void> onLoad() async {
    appLogger.d("IdleGame.onLoad()");
    resourcePanelComponent = ResourcePanelComponent(
      position: Vector2.zero(),
      size: Vector2(size.x, 24 + 8 + 8 + 16 + 16),
    );
    add(resourcePanelComponent);

    _playgroundList = ScrollableComponentList(
      position: Vector2(0, 50),
      size: Vector2(size.x, size.y - 100),
    );

    await add(_playgroundList);

    await _playgroundList.setItems([
      ...gameStateNotifier.currentData.playgrounds.map((playground) {
        return PlaygroundComponent(playground: playground);
      }),
    ]);

    bottomPanelComponent = BottomPanelComponent(
      anchor: Anchor.bottomRight,
      position: Vector2(size.x, size.y),
      size: Vector2(size.x, 24 + 8 + 8 + 16 + 16),
      onPressed: addPlayground,
    );
    add(bottomPanelComponent);

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (isLoaded) {
      resourcePanelComponent
        ..position.setZero()
        ..size.setValues(size.x, 24 + 8 + 8 + 16 + 16);
      _playgroundList
        ..position.setValues(0, 24 + 8 + 8 + 16 + 16)
        ..size.setValues(size.x, size.y - (24 + 8 + 8 + 16 + 16) * 2);
      bottomPanelComponent
        ..position.setValues(size.x, size.y)
        ..size.setValues(size.x, 24 + 8 + 8 + 16 + 16);
    }
  }

  void displayUpgradeOverlay(int id) {
    upgradeOverlayPlaygroundId = id;
    overlays.add(IdleGame.upgradeOverlay);
  }

  void dismissUpgradeOverlay() {
    upgradeOverlayPlaygroundId = null;
    overlays.remove(IdleGame.upgradeOverlay);
  }

  void dismissTutorialOverlay() {
    overlays.remove(IdleGame.tutorialOverlay);
  }

  Future<void> addPlayground() async {
    final playground = gameStateNotifier.addPlayground();

    await _playgroundList.addItem(PlaygroundComponent(playground: playground));
  }
}
