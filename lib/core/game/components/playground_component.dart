import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/circle_button_component.dart';
import 'package:idle_game/core/game/components/rectangle_button_component.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/core/game/components/encounter_component.dart';
import 'package:idle_game/core/game/components/worker_component.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/resource_model.dart';

class PlaygroundComponent extends RectangleComponent
    with HasGameReference<IdleGame>, TapCallbacks {
  final PlaygroundModel _playground;
  final ResourceType _resourceType;
  double encounterTimer = 0;
  static const double _padding = 10.0;
  static const double _encounterRadius = 24.0;
  static const double _height = 150.0;

  PlaygroundComponent({
    required ResourceType type,
    required PlaygroundModel playground,
  }) : _playground = playground,
       _resourceType = type;

  late RowComponent _buttonsComponent;

  late TextComponent _nameComponent;
  late IconComponent _upgradeCostTypeComponent;
  late TextComponent _upgradeCostComponent;
  late TextComponent _rateComponent;

  late RectangleButtonComponent _addButton;
  late RectangleButtonComponent _subtractButton;
  late CircleButtonComponent _upgradeButton;
  late CircleButtonComponent _downgradeButton;
  late CircleButtonComponent _resetButton;
  late CircleButtonComponent _stopButton;

  late WorkerComponent _workerComponent;

  String? _lastUpgradeCostText;
  String? _lastRateText;
  Vector2? _lastSize;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(200, _height);
    final playground = game.gameStateNotifier.getPlaygroundById(_playground.id);

    paint = Paint()..color = playground.backgroundColor;

    _lastUpgradeCostText = _formatUpgradeCost(playground.getUpgradeCost());
    _lastRateText = _formatRate(playground.generationRatePerSecond);

    _nameComponent = TextComponent(text: playground.name);

    _upgradeCostTypeComponent = IconComponent(
      icon: playground.upgradeCostType.icon,
      size: Vector2.all(12),
    );

    _upgradeCostComponent = TextComponent(
      text: _lastUpgradeCostText,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 12.0, color: BasicPalette.white.color),
      ),
    );

    _rateComponent = TextComponent(
      anchor: Anchor.bottomRight,
      text: _lastRateText,
      position: Vector2(width - _padding, height - _padding),
      priority: 5,
    );

    _addButton = RectangleButtonComponent(
      icon: Icons.add_circle_outline,
      onPressed: () {
        moveOnClick();
        game.gameStateNotifier.add(_resourceType, 1.0);
      },
      onHold: () {
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
        game.gameStateNotifier.buyPlaygroundUpgrade(_playground.id);
      },
    );

    _downgradeButton = CircleButtonComponent(
      icon: Icons.trending_down,
      onPressed: () {
        game.gameStateNotifier.downgradePlayground(_playground.id, 0.1);
      },
    );

    _resetButton = CircleButtonComponent(
      icon: Icons.restart_alt,
      onPressed: () {
        resetEncounters();
        game.gameStateNotifier.resetResource(_resourceType);
      },
    );

    _stopButton = CircleButtonComponent(
      icon: Icons.stop_circle_outlined,
      onPressed: () {
        game.gameStateNotifier.resetPlayground(_playground.id);
      },
    );

    _buttonsComponent = RowComponent(
      anchor: Anchor.topRight,
      position: Vector2(width - _padding, _padding),
      gap: 10.0,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RowComponent(
          gap: 10.0,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ColumnComponent(gap: 10, children: [_addButton, _subtractButton]),
            ColumnComponent(
              gap: 10,
              children: [_upgradeButton, _downgradeButton],
            ),
            ColumnComponent(gap: 10, children: [_resetButton, _stopButton]),
          ],
        ),
      ],
      priority: 5,
    );

    add(_buttonsComponent);
    add(_rateComponent);

    add(
      RowComponent(
        position: Vector2(_padding, _padding),
        gap: 10,
        priority: 5,
        children: [
          _nameComponent,
          _upgradeCostTypeComponent,
          _upgradeCostComponent,
        ],
      ),
    );

    _workerComponent = WorkerComponent(
      playgroundModel: _playground,
      workerModel: _playground.worker,
      position: Vector2(_padding, height - _padding),
      anchor: Anchor.bottomLeft,
    );
    add(_workerComponent);

    _updateResponsivePositions(force: true);
  }

  @override
  void update(double dt) {
    final resource = game.gameStateNotifier.getResourceByType(_resourceType);
    final playground = game.gameStateNotifier.getPlaygroundById(_playground.id);

    _updateText(playground);
    _updateResponsivePositions();

    if (playground.generationRatePerSecond > 0 && !playground.encounter) {
      encounterTimer += dt * playground.generationRatePerSecond * 10;
    }

    if (encounterTimer >= playground.encounterInterval) {
      encounterTimer = 0;
      generateEncounter(playground);
    }

    _upgradeButton.isDisabled = !playground.canBuyUpgrade(resource.amount);
    _resetButton.isDisabled =
        playground.generationRatePerSecond == 0 && resource.amount == 0;
    _stopButton.isDisabled = playground.generationRatePerSecond == 0;

    super.update(dt);
  }

  void _updateText(PlaygroundModel playground) {
    final amountText = _formatUpgradeCost(playground.getUpgradeCost());
    if (_lastUpgradeCostText != amountText) {
      _lastUpgradeCostText = amountText;
      _upgradeCostComponent.text = amountText;
    }

    final rateText = _formatRate(playground.generationRatePerSecond);
    if (_lastRateText != rateText) {
      _lastRateText = rateText;
      _rateComponent.text = rateText;
    }
  }

  void _updateResponsivePositions({bool force = false}) {
    if (!force && _lastSize?.x == width && _lastSize?.y == height) {
      return;
    }

    _lastSize = size.clone();

    _rateComponent.position.setValues(width - _padding, height - _padding);
    _buttonsComponent.position.setValues(width - _padding, _padding);
    _workerComponent.position.setValues(_padding, height - _padding);
  }

  String _formatUpgradeCost(double cost) => cost.toStringAsExponential(2);

  String _formatRate(double rate) => '(${rate.toStringAsExponential(2)}/s)';

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    moveOnClick();
  }

  void generateEncounter([PlaygroundModel? cachedPlayground]) {
    final playground =
        cachedPlayground ??
        game.gameStateNotifier.getPlaygroundById(_playground.id);

    final defaultSpawnX = width + (_padding * 2);
    final encounterWidth = _encounterRadius * 2;

    var hasEncounters = false;
    var maxEncounterX = double.negativeInfinity;

    for (final encounter in children.whereType<EncounterComponent>()) {
      hasEncounters = true;

      if (encounter.x - encounterWidth > width) {
        return;
      }

      if (encounter.x > maxEncounterX) {
        maxEncounterX = encounter.x;
      }
    }

    final spawnX = hasEncounters
        ? maxEncounterX + encounterWidth + playground.encounterSpacing
        : defaultSpawnX;

    final encounter = EncounterComponent(
      playgroundModel: playground,
      encounterModel: playground.encounters.getNext(),
      radius: _encounterRadius,
      position: Vector2(spawnX, height - _padding),
      anchor: Anchor.bottomLeft,
    );

    add(encounter);
  }

  void resetEncounters() {
    for (final encounter in children.whereType<EncounterComponent>().toList()) {
      encounter.removeFromParent();
    }
  }

  void moveOnClick() {
    final currentPlayground = game.gameStateNotifier.getPlaygroundById(
      _playground.id,
    );
    encounterTimer += currentPlayground.encounterInterval / 10;

    for (final encounter in children.whereType<EncounterComponent>()) {
      encounter.moveOnClick();
    }
  }
}
