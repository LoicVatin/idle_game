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
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/resting_spot_model.dart';

class PlaygroundComponent extends RectangleComponent
    with HasGameReference<IdleGame>, TapCallbacks {
  final PlaygroundModel _playground;
  double encounterTimer = 0;
  static const double _padding = 10.0;
  static const double _encounterRadius = 24.0;
  static const double _height = 200.0;

  PlaygroundComponent({required PlaygroundModel playground})
    : _playground = playground;

  late RowComponent _buttonsComponent;
  late ColumnComponent _switchSceneComponent;
  final Map<int, RectangleButtonComponent> _switchSceneButtons = {};

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

  int? _activeSceneId;
  String? _lastSceneName;
  String? _lastUpgradeCostText;
  String? _lastRateText;
  ResourceType _lastUpgradeCostType = ResourceType.wood;
  Vector2? _lastSize;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(200, _height);
    final playground = game.gameStateNotifier.getPlaygroundById(_playground.id);
    final scene = playground.activeScene;

    paint = Paint()..color = scene.backgroundColor;

    _activeSceneId = scene.id;
    _lastSceneName = scene.name;
    _lastUpgradeCostText = _formatUpgradeCost(scene.getUpgradeCost());
    _lastRateText = _formatRate(scene.generationRatePerSecond);
    _lastUpgradeCostType = scene.upgradeCostType;

    _nameComponent = TextComponent(text: _lastSceneName);

    _upgradeCostTypeComponent = IconComponent(
      icon: _lastUpgradeCostType.icon,
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
      position: Vector2(width - _padding - 24 * 2, height - _padding),
      priority: 5,
    );

    _addButton = RectangleButtonComponent(
      icon: Icons.add_circle_outline,
      onPressed: () {
        moveOnClick();
        game.gameStateNotifier.add(_lastUpgradeCostType, 1.0);
      },
      onHold: () {
        game.gameStateNotifier.add(_lastUpgradeCostType, 1.0);
      },
    );

    _subtractButton = RectangleButtonComponent(
      icon: Icons.remove_circle_outline,
      onPressed: () {
        game.gameStateNotifier.subtract(_lastUpgradeCostType, 1.0);
      },
    );

    _upgradeButton = CircleButtonComponent(
      icon: Icons.trending_up,
      onPressed: () {
        game.gameStateNotifier.buyActiveSceneUpgrade(_playground.id);
      },
    );

    _downgradeButton = CircleButtonComponent(
      icon: Icons.trending_down,
      onPressed: () {
        game.gameStateNotifier.downgradeScene(_playground.id, 0.1);
      },
    );

    _resetButton = CircleButtonComponent(
      icon: Icons.restart_alt,
      onPressed: () {
        resetEncounters();
        game.gameStateNotifier.resetResource(_lastUpgradeCostType);
      },
    );

    _stopButton = CircleButtonComponent(
      icon: Icons.stop_circle_outlined,
      onPressed: () {
        game.gameStateNotifier.resetScene(_playground.id);
      },
    );

    _buttonsComponent = RowComponent(
      anchor: Anchor.topRight,
      position: Vector2(width - _padding - 24 * 2, _padding),
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

    _switchSceneComponent = ColumnComponent(
      size: Vector2(24 * 2, height),
      anchor: Anchor.topRight,
      position: Vector2(x, 0),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      priority: 10,
      children: [
        ...playground.scenes.map((scene) {
          final button = RectangleButtonComponent(
            icon: scene.icon,
            onPressed: () {
              resetEncounters();
              game.gameStateNotifier.switchActiveScene(playground.id, scene.id);
            },
          )..isDisabled = scene.id == _activeSceneId;
          _switchSceneButtons[scene.id] = button;
          return button;
        }),
        RectangleButtonComponent(
          icon: Icons.settings,
          onPressed: () {
            game.displayUpgradeOverlay(playground.id);
          },
        ),
      ],
    );
    add(_switchSceneComponent);

    _updateResponsivePositions(force: true);
  }

  @override
  void update(double dt) {
    final playground = game.gameStateNotifier.getPlaygroundById(_playground.id);
    final scene = playground.activeScene;
    final resource = game.gameStateNotifier.getResourceByType(
      scene.upgradeCostType,
    );

    _updateScene(scene);
    _updateResponsivePositions();

    if (scene is RestingSpotModel) {
      playground.worker.restoreHealth(
        scene.generationRatePerSecond * scene.healthRegenPerSecond * dt,
      );
      playground.worker.restoreStamina(
        scene.generationRatePerSecond * scene.staminaRegenPerSecond * dt,
      );
      resetEncounters();
      encounterTimer = 0;
    } else {
      if (scene.generationRatePerSecond > 0 && !scene.encounter) {
        encounterTimer += dt * scene.generationRatePerSecond * 10;
      }

      if (encounterTimer >= scene.encounterInterval) {
        encounterTimer = 0;
        generateEncounter(scene);
      }
    }

    _upgradeButton.isDisabled = !scene.canBuyUpgrade(resource.amount);
    _resetButton.isDisabled =
        scene.generationRatePerSecond == 0 && resource.amount == 0;
    _stopButton.isDisabled = scene.generationRatePerSecond == 0;

    super.update(dt);
  }

  void _updateScene(SceneModel scene) {
    final sceneId = scene.id;
    if (_activeSceneId != sceneId) {
      paint = Paint()..color = scene.backgroundColor;
      _activeSceneId = sceneId;

      for (final buttonEntry in _switchSceneButtons.entries) {
        buttonEntry.value.isDisabled = buttonEntry.key == sceneId;
      }
    }

    final sceneName = scene.name;
    if (_lastSceneName != sceneName) {
      _lastSceneName = sceneName;
      _nameComponent.text = sceneName;
    }

    final upgradeCostText = _formatUpgradeCost(scene.getUpgradeCost());
    if (_lastUpgradeCostText != upgradeCostText) {
      _lastUpgradeCostText = upgradeCostText;
      _upgradeCostComponent.text = upgradeCostText;
    }

    final upgradeCostType = scene.upgradeCostType;
    if (_lastUpgradeCostType != upgradeCostType) {
      _upgradeCostTypeComponent.icon = upgradeCostType.icon;
      _lastUpgradeCostType = upgradeCostType;
    }

    final rateText = _formatRate(scene.generationRatePerSecond);
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

    _rateComponent.position.setValues(
      width - _padding - 24 * 2,
      height - _padding,
    );
    _buttonsComponent.position.setValues(width - _padding - 24 * 2, _padding);
    _workerComponent.position.setValues(_padding, height - _padding);
    _switchSceneComponent.position.setValues(width, 0);
  }

  String _formatUpgradeCost(double cost) => cost.toStringAsExponential(2);

  String _formatRate(double rate) => '(${rate.toStringAsExponential(2)}/s)';

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    moveOnClick();
  }

  void generateEncounter([SceneModel? cachedScene]) {
    final scene =
        cachedScene ??
        game.gameStateNotifier.getPlaygroundById(_playground.id).activeScene;

    if (scene is RestingSpotModel) {
      return;
    }

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
        ? maxEncounterX + encounterWidth + scene.encounterSpacing
        : defaultSpawnX;

    final encounter = EncounterComponent(
      sceneModel: scene,
      encounterModel: scene.encounters.getNext(),
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
    final playground = game.gameStateNotifier.getPlaygroundById(_playground.id);
    final scene = playground.activeScene;

    if (scene is RestingSpotModel) {
      RestingSpotModel restingSpotModel = scene;
      playground.worker.restoreHealth(
        restingSpotModel.generationRatePerSecond *
            restingSpotModel.healthRegenPerSecond,
      );
      playground.worker.restoreStamina(
        restingSpotModel.generationRatePerSecond *
            restingSpotModel.staminaRegenPerSecond,
      );
    } else {
      encounterTimer += scene.encounterInterval / 10;

      for (final encounter in children.whereType<EncounterComponent>()) {
        encounter.moveOnClick();
      }
    }
  }

  void switchScene() {
    final previousScene = game.gameStateNotifier
        .getPlaygroundById(_playground.id)
        .activeScene;

    resetEncounters();
    paint = Paint()..color = previousScene.backgroundColor;

    //_renderedActiveSceneId =
  }
}
