import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:idle_game/presentation/core/game_provider.dart';

class IdleGame extends FlameGame with TapCallbacks {
  final GameStateNotifier gameStateNotifier;

  late final TextComponent woodComponent;
  late final ColumnComponent columnComponent;
  late final CircleComponent addButton;
  late final CircleComponent subtractButton;
  late final CircleComponent upgradeButton;
  late final CircleComponent downgradeButton;

  IdleGame({required this.gameStateNotifier});

  @override
  Color backgroundColor() => const Color(0xFF101820);

  @override
  Future<void> onLoad() async {
    woodComponent = TextComponent(
      text:
          '${gameStateNotifier.currentData.wood.type.name} : '
          '${gameStateNotifier.currentData.wood.amount.toStringAsFixed(2)}'
          ' (${gameStateNotifier.currentData.wood.generationRatePerSecond.toStringAsFixed(2)}/s)',
    );

    addButton = CircleComponent(
      radius: 30,
      paint: Paint()..color = Colors.deepPurple,
      children: [
        IconComponent(
          icon: Icons.add_circle_outline,
          size: Vector2.all(30),
          anchor: Anchor.center,
          position: Vector2.all(30),
        ),
      ],
    );

    subtractButton = CircleComponent(
      radius: 30,
      paint: Paint()..color = Colors.deepPurple,
      children: [
        IconComponent(
          icon: Icons.remove_circle_outline,
          size: Vector2.all(30),
          anchor: Anchor.center,
          position: Vector2.all(30),
        ),
      ],
    );

    upgradeButton = CircleComponent(
      radius: 30,
      paint: Paint()..color = Colors.deepPurple,
      children: [
        IconComponent(
          icon: Icons.trending_up,
          size: Vector2.all(30),
          anchor: Anchor.center,
          position: Vector2.all(30),
        ),
      ],
    );

    downgradeButton = CircleComponent(
      radius: 30,
      paint: Paint()..color = Colors.deepPurple,
      children: [
        IconComponent(
          icon: Icons.trending_down,
          size: Vector2.all(30),
          anchor: Anchor.center,
          position: Vector2.all(30),
        ),
      ],
    );

    columnComponent = ColumnComponent(
      size: size,
      gap: 10.0,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        woodComponent,
        addButton,
        subtractButton,
        upgradeButton,
        downgradeButton,
      ],
    );

    add(columnComponent);

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

    woodComponent.text =
        '${gameStateNotifier.currentData.wood.type.name} : '
        '${gameStateNotifier.currentData.wood.amount.toStringAsFixed(2)}'
        ' (${gameStateNotifier.currentData.wood.generationRatePerSecond.toStringAsFixed(2)}/s)';

    gameStateNotifier.updateResource(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (upgradeButton.containsPoint(event.localPosition)) {
      gameStateNotifier.upgradeResource(0.1);
    }
    if (downgradeButton.containsPoint(event.localPosition)) {
      gameStateNotifier.downgradeResource(0.1);
    }
    if (addButton.containsPoint(event.localPosition)) {
      gameStateNotifier.add(1.0);
    }
    if (subtractButton.containsPoint(event.localPosition)) {
      gameStateNotifier.subtract(1.0);
    }

    super.onTapDown(event);
  }
}
