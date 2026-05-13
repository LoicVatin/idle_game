import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/IdleGame.dart';
import 'package:idle_game/core/game/components/encounter_component.dart';
import 'package:idle_game/core/game/components/rectangle_button_component.dart';
import 'package:idle_game/core/game/components/worker_component.dart';
import 'package:idle_game/data/models/resource_model.dart';

import 'circle_button_component.dart';

class ResourceComponent extends PositionComponent
    with HasGameReference<IdleGame>, TapCallbacks {
  final ResourceType _resourceType;

  ResourceComponent({required ResourceType type}) : _resourceType = type;

  late RowComponent _buttonsComponent;

  late TextComponent _typeComponent;
  late TextComponent _amountComponent;
  late TextComponent _rateComponent;

  late RectangleButtonComponent _addButton;
  late RectangleButtonComponent _subtractButton;
  late CircleButtonComponent _upgradeButton;
  late CircleButtonComponent _downgradeButton;
  late CircleButtonComponent _resetButton;
  late CircleButtonComponent _stopButton;

  late WorkerComponent _workerComponent;
  late EncounterComponent _encounterComponent;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(game.size.x, 150);
    final resource = game.gameStateNotifier.get(_resourceType);

    _typeComponent = TextComponent(text: resource.type.name, priority: 5);

    _amountComponent = TextComponent(
      text: resource.amount.toStringAsFixed(2),
      priority: 5,
    );

    _rateComponent = TextComponent(
      anchor: Anchor.bottomRight,
      text: '(${resource.generationRatePerSecond.toStringAsFixed(2)}/s)',
      position: size,
      priority: 5,
    );

    _addButton = RectangleButtonComponent(
      icon: Icons.add_circle_outline,
      onPressed: () {
        game.gameStateNotifier.add(_resourceType, 1.0);
      },
    );

    _subtractButton = RectangleButtonComponent(
      icon: Icons.remove_circle_outline,
      onPressed: () {
        game.gameStateNotifier.subtract(_resourceType, 1.0);
      },
    );

    _upgradeButton = CircleButtonComponent(
      icon: Icons.trending_up,
      onPressed: () {
        game.gameStateNotifier.upgradeResource(_resourceType, 0.1);
      },
    );

    _downgradeButton = CircleButtonComponent(
      icon: Icons.trending_down,
      onPressed: () {
        game.gameStateNotifier.downgradeResource(_resourceType, 0.1);
      },
    );

    _resetButton = CircleButtonComponent(
      icon: Icons.restart_alt,
      onPressed: () {
        game.gameStateNotifier.resetResource(
          _resourceType,
          amount: true,
          rate: true,
        );
      },
    );

    _stopButton = CircleButtonComponent(
      icon: Icons.stop_circle_outlined,
      onPressed: () {
        game.gameStateNotifier.resetResource(_resourceType, rate: true);
      },
    );

    _buttonsComponent = RowComponent(
      size: size,
      gap: 10.0,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColumnComponent(gap: 10, children: [_addButton, _subtractButton]),
        ColumnComponent(gap: 10, children: [_upgradeButton, _downgradeButton]),
        ColumnComponent(gap: 10, children: [_resetButton, _stopButton]),
      ],
      priority: 5,
    );

    add(_buttonsComponent);
    add(_rateComponent);

    add(RowComponent(gap: 10, children: [_typeComponent, _amountComponent]));

    _workerComponent = WorkerComponent(
      type: _resourceType,
      position: Vector2(10, size.y - 10),
      anchor: Anchor.bottomLeft,
    );
    add(_workerComponent);

    _encounterComponent = EncounterComponent(
      type: _resourceType,
      position: Vector2(size.x - 10, size.y - 10),
      anchor: Anchor.bottomRight,
    );
    add(_encounterComponent);
  }

  @override
  void update(double dt) {
    final resource =
        game.gameStateNotifier.currentData.resources[_resourceType];

    _typeComponent.text = resource!.type.name;

    _amountComponent.text = resource.amount.toStringAsFixed(2);

    _rateComponent
      ..text = '(${resource.generationRatePerSecond.toStringAsFixed(2)}/s)'
      ..position = size;

    _buttonsComponent.size = size;
  }

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()
      ..color = switch (_resourceType) {
        ResourceType.food => Colors.redAccent,
        ResourceType.wood => Colors.brown,
        ResourceType.stone => Colors.grey,
      };
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      this.size = Vector2(game.size.x, 150);
      _buttonsComponent.size = this.size;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
  }
}
