import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/resource_component.dart';
import 'package:idle_game/core/game/components/scrollable_component_list.dart';
import 'package:idle_game/data/models/resource_model.dart';
import 'package:idle_game/presentation/core/game_provider.dart';

class IdleGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final GameStateNotifier gameStateNotifier;

  IdleGame({required this.gameStateNotifier});

  late final ScrollableComponentList _resourceList;

  @override
  Color backgroundColor() => Colors.black;

  @override
  Future<void> onLoad() async {
    _resourceList = ScrollableComponentList(
      position: Vector2.zero(),
      size: Vector2(size.x, size.y),
    );

    await add(_resourceList);

    await _resourceList.setItems([
      ResourceComponent(type: ResourceType.wood),
      ResourceComponent(type: ResourceType.stone),
      ResourceComponent(type: ResourceType.food),
    ]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameStateNotifier.updateResource(dt);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (isLoaded) {
      _resourceList
        ..position.setZero()
        ..size = size.clone();
    }
  }
}
