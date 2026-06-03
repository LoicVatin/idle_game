import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/circle_button_component.dart';
import 'package:idle_game/core/game/components/resource_panel_component.dart';
import 'package:idle_game/core/game/components/scrollable_component_list.dart';
import 'package:idle_game/presentation/core/game_provider.dart';

import 'components/playground_component.dart';

class IdleGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final GameStateNotifier gameStateNotifier;

  IdleGame({required this.gameStateNotifier});

  late final ResourcePanelComponent _resourcePanelComponent;
  late final ScrollableComponentList _playgroundList;
  late final CircleButtonComponent _button;

  static const String upgradeOverlay = 'upgrade_overlay';
  int? upgradeOverlayPlaygroundId;

  @override
  Color backgroundColor() => Colors.indigo;

  @override
  Future<void> onLoad() async {
    _resourcePanelComponent = ResourcePanelComponent(
      position: Vector2.zero(),
      size: Vector2(size.x, 24 + 8 + 8 + 16 + 16),
    );
    add(_resourcePanelComponent);

    _playgroundList = ScrollableComponentList(
      position: Vector2(0, 50),
      size: Vector2(size.x, size.y - 50),
    );

    await add(_playgroundList);

    await _playgroundList.setItems([
      ...gameStateNotifier.currentData.playgrounds.map((playground) {
        return PlaygroundComponent(playground: playground);
      }),
    ]);

    _button = CircleButtonComponent(
      anchor: Anchor.bottomRight,
      position: Vector2(size.x - 100, size.y - 50),
      icon: Icons.add,
      onPressed: () {
        addPlayground();
      },
    );
    add(_button);

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (isLoaded) {
      _resourcePanelComponent
        ..position.setZero()
        ..size.setValues(size.x, 24 + 8 + 8 + 16 + 16);
      _playgroundList
        ..position.setValues(0, 24 + 8 + 8 + 16 + 16)
        ..size.setValues(size.x, size.y - (24 + 8 + 8 + 16 + 16));
      _button.position.setValues(size.x - 100, size.y - 50);
    }
  }

  @override
  void update(double dt) {
    _button.isDisabled = gameStateNotifier.currentData.playgrounds.length == 5;
    super.update(dt);
  }

  void displayUpgradeOverlay(int id) {
    upgradeOverlayPlaygroundId = id;
    overlays.add(IdleGame.upgradeOverlay);
  }

  void dismissUpgradeOverlay() {
    upgradeOverlayPlaygroundId = null;
    overlays.remove(IdleGame.upgradeOverlay);
  }

  Future<void> addPlayground() async {
    final playground = gameStateNotifier.addPlayground();

    await _playgroundList.addItem(PlaygroundComponent(playground: playground));
  }
}
