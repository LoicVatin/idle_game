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
  double encounterTimer = 0;
  static const double _padding = 10.0;

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
      position: Vector2(size.x - _padding, size.y - _padding),
      priority: 5,
    );

    _addButton = RectangleButtonComponent(
      icon: Icons.add_circle_outline,
      onPressed: () {
        encounterTimer += 0.25;
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
      position: Vector2(_padding, _padding),
      size: Vector2(size.x - _padding * 2, size.y - _padding * 2),
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

    add(
      RowComponent(
        position: Vector2(_padding, _padding),
        gap: 10,
        children: [_typeComponent, _amountComponent],
      ),
    );

    _workerComponent = WorkerComponent(
      type: _resourceType,
      position: Vector2(_padding, size.y - _padding),
      anchor: Anchor.bottomLeft,
    );
    add(_workerComponent);
  }

  @override
  void update(double dt) {
    final resource =
        game.gameStateNotifier.currentData.resources[_resourceType];

    _typeComponent.text = resource!.type.name;

    _amountComponent.text = resource.amount.toStringAsFixed(2);

    _rateComponent
      ..text = '(${resource.generationRatePerSecond.toStringAsFixed(2)}/s)'
      ..position = Vector2(size.x - _padding, size.y - _padding);

    _buttonsComponent.size = Vector2(
      size.x - _padding * 2,
      size.y - _padding * 2,
    );

    if (resource.generationRatePerSecond > 0) {
      encounterTimer += dt;
    }
    if (encounterTimer >=
        (resource.encounterInterval - resource.generationRatePerSecond)) {
      encounterTimer = 0;
      generateEncounter();
    }
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
      _buttonsComponent.size = Vector2(
        this.size.x - _padding * 2,
        this.size.y - _padding * 2,
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
  }

  void generateEncounter() {
    final encounter = EncounterComponent(
      type: _resourceType,
      health: 3,
      reward: 5,
      position: Vector2(size.x + (_padding * 2), size.y - _padding),
      anchor: Anchor.bottomRight,
    );

    add(encounter);
  }
}
