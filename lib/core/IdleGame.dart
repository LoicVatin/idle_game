import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:idle_game/presentation/core/game_provider.dart';

class IdleGame extends FlameGame with TapCallbacks {
  late final ColumnComponent columnComponent;
  late final TextComponent counterText;
  late final CircleComponent button;

  final GameStateNotifier gameStateNotifier;

  IdleGame({required this.gameStateNotifier});

  @override
  Color backgroundColor() => const Color(0xFF101820);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    counterText = TextComponent(
      text: '${gameStateNotifier.currentData.counter}',
      textRenderer: TextPaint(
        style: Theme.of(buildContext!).textTheme.headlineMedium,
      ),
    );

    button = CircleComponent(
      anchor: Anchor.bottomRight,
      position: Vector2(size.x - 30, size.y - 30),
      radius: 30,
      paint: Paint()..color = Colors.deepPurple,
      children: [
        IconComponent(
          icon: Icons.add,
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
        TextComponent(text: 'You have pushed the button this many times:'),
        counterText,
      ],
    );

    add(columnComponent);
    add(button);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (isLoaded) {
      columnComponent.size = size;
      button.position = Vector2(size.x - 30, size.y - 30);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (button.containsPoint(event.localPosition)) {
      gameStateNotifier.incrementCounter();
    }
  }
}
