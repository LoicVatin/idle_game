import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';

import 'package:flame/game.dart';
import 'package:idle_game/core/game/components/resource_component.dart';
import 'package:idle_game/presentation/core/game_provider.dart';

import '../../data/models/resource_model.dart';

class IdleGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final GameStateNotifier gameStateNotifier;

  IdleGame({required this.gameStateNotifier});

  @override
  Color backgroundColor() => const Color(0xFF101820);

  @override
  Future<void> onLoad() async {
    ColumnComponent column = ColumnComponent(
      gap: 20,
      children: [
        ResourceComponent(type: ResourceType.wood),
        ResourceComponent(type: ResourceType.stone),
        ResourceComponent(type: ResourceType.food),
      ],
    );
    add(column);

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (isLoaded) {
      columnComponent.size = size;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    gameStateNotifier.updateResource(dt);
  }
}
