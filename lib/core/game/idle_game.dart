import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/resource_panel_component.dart';
import 'package:idle_game/core/game/components/scrollable_component_list.dart';
import 'package:idle_game/presentation/core/game_provider.dart';

import 'components/playground_component.dart';

class IdleGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final GameStateNotifier gameStateNotifier;

  IdleGame({required this.gameStateNotifier});

  late final ResourcePanelComponent _resourcePanelComponent;
  late final ScrollableComponentList _playgroundList;

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
        return PlaygroundComponent(
          type: playground.upgradeCostType,
          playground: playground,
        );
      }),
    ]);

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
    }
  }
}
