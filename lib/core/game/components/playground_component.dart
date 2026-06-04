import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/circle_button_component.dart';
import 'package:idle_game/core/game/components/rectangle_button_component.dart';
import 'package:idle_game/core/game/components/status_bar_component.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/core/game/components/encounter_component.dart';
import 'package:idle_game/core/game/components/worker_component.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/data/models/worker_model.dart';

class PlaygroundComponent extends RectangleComponent
    with HasGameReference<IdleGame>, TapCallbacks {
  final PlaygroundModel _playground;
  double encounterTimer = 0;
  static const double _padding = 10.0;
  static const double _encounterRadius = 24.0;
  static const double _height = 200.0;
  static const double _sceneSwitchRecoveryHealthPercent = 0.25;
  static const double _sceneTransitionDuration = 0.4;

  PlaygroundComponent({required PlaygroundModel playground})
    : _playground = playground;

  late RowComponent _buttonsComponent;
  late ColumnComponent _headerComponent;
  late ColumnComponent _switchSceneComponent;
  late RectangleComponent _sceneFadeComponent;
  late RectangleComponent _defeatFadeComponent;
  final Map<int, RectangleButtonComponent> _switchSceneButtons = {};
  bool _switchScenesLockedUntilRecovered = false;
  bool _isSceneTransitioning = false;
  double _sceneTransitionElapsed = 0;
  int? _sceneTransitionTargetId;
  bool _isDefeatTransitioning = false;
  double _defeatTransitionElapsed = 0;
  int? _defeatRestSceneId;

  late TextComponent _nameComponent;
  late TextComponent _rateComponent;

  late RectangleButtonComponent _addButton;
  late RectangleButtonComponent _subtractButton;
  late CircleButtonComponent _upgradeButton;
  late CircleButtonComponent _downgradeButton;
  late CircleButtonComponent _resetButton;
  late CircleButtonComponent _stopButton;

  late WorkerComponent _workerComponent;
  late TextComponent _workerLevelComponent;
  late StatusBarComponent _workerExperienceComponent;

  int? _activeSceneId;
  String? _lastSceneName;
  String? _lastRateText;
  Vector2? _lastSize;
  double? _resourceAmount;
  double? _experienceRequired;
  int? _currentLevel;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(200, _height);
    final playground = game.gameStateNotifier.getPlaygroundById(_playground.id);
    final scene = playground.activeScene;

    paint = Paint()..color = scene.backgroundColor;

    _activeSceneId = scene.id;
    _lastSceneName = scene.name;
    _lastRateText = _formatRate(scene.generationRatePerSecond);
    _currentLevel = playground.worker.level;

    _nameComponent = TextComponent(text: _lastSceneName);

    _workerLevelComponent = TextComponent(text: "Lvl. $_currentLevel");

    _workerExperienceComponent = StatusBarComponent();

    _rateComponent = TextComponent(
      anchor: Anchor.bottomRight,
      text: _lastRateText,
      position: Vector2(width - _padding - 24 * 2, height - _padding),
      priority: 10,
    );

    _addButton = RectangleButtonComponent(
      icon: Icons.add_circle_outline,
      onPressed: () {
        moveOnClick();
        addResource();
      },
      onHold: () {
        addResource();
      },
    );

    _subtractButton = RectangleButtonComponent(
      icon: Icons.remove_circle_outline,
      onPressed: () {
        subtractResource();
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
        resetResource();
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
      priority: 100,
    );

    _headerComponent = ColumnComponent(
      position: Vector2.all(_padding),
      children: [
        _nameComponent,
        _workerLevelComponent,
        _workerExperienceComponent,
      ], priority: 10
    );

    add(_buttonsComponent);
    add(_headerComponent);
    add(_rateComponent);

    _workerComponent = WorkerComponent(
      playgroundModel: _playground,
      workerModel: _playground.worker,
      position: Vector2(_padding, height - _padding),
      anchor: Anchor.bottomLeft,
      onDefeated: _handleWorkerDefeated,
    );
    add(_workerComponent);

    _switchSceneComponent = ColumnComponent(
      size: Vector2(24 * 2, height),
      anchor: Anchor.topRight,
      position: Vector2(x, 0),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      priority: 100,
      children: [
        ...playground.scenes.map((scene) {
          final button =
              RectangleButtonComponent(
                  icon: scene.icon,
                  onPressed: () {
                    _startSceneTransition(playground.id, scene.id);
                  },
                )
                ..isDisabled =
                    (scene.id == _activeSceneId &&
                    _switchScenesLockedUntilRecovered);
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

    _sceneFadeComponent = RectangleComponent(
      size: size.clone(),
      paint: Paint()..color = Colors.black.withOpacity(0),
      priority: 25,
    );
    add(_sceneFadeComponent);

    _defeatFadeComponent = RectangleComponent(
      size: size.clone(),
      paint: Paint()..color = Colors.red.withOpacity(0),
      priority: 75,
    );
    add(_defeatFadeComponent);

    _updateResponsivePositions(force: true);
  }

  @override
  void update(double dt) {
    final scene = _playground.activeScene;
    final resource = game.gameStateNotifier.getResourceByType(
      scene.upgradeCostType,
    );

    _updateSceneTransition(dt);
    _updateDefeatTransition(dt);
    _updateSceneSwitchLock(_playground.worker);
    _updateScene(scene);
    _updateResponsivePositions();

    if (scene is RestSceneModel) {
      _playground.worker.restoreHealth(
        scene.generationRatePerSecond * scene.healthRegenPerSecond * dt,
      );
      _playground.worker.restoreStamina(
        scene.generationRatePerSecond * scene.staminaRegenPerSecond * dt,
      );
      encounterTimer = 0;
    } else if (scene is EncounterSceneModel) {
      if (scene.generationRatePerSecond > 0 && !scene.encounter) {
        encounterTimer += dt * scene.generationRatePerSecond * 10;
      }

      if (encounterTimer >= scene.encounterInterval) {
        encounterTimer = 0;
        generateEncounter(scene);
      }
    }

    _updateSceneSwitchLock(_playground.worker);
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

      _updateSwitchSceneButtons();
      for (final buttonEntry in _switchSceneButtons.entries) {
        buttonEntry.value.isDisabled = buttonEntry.key == sceneId;
      }
    }

    for (final encounter in children.whereType<EncounterComponent>()) {
      final isActiveEncounter = encounter.sceneModel.id == sceneId;
      encounter.isSceneActive = isActiveEncounter;
      encounter.isVisible = isActiveEncounter;
    }

    final sceneName = scene.name;
    if (_lastSceneName != sceneName) {
      _lastSceneName = sceneName;
      _nameComponent.text = sceneName;
    }

    final rateText = _formatRate(scene.generationRatePerSecond);
    if (_lastRateText != rateText) {
      _lastRateText = rateText;
      _rateComponent.text = rateText;
    }

    final level = _playground.worker.level;
    if (_currentLevel != level) {
      _currentLevel = level;
      _workerLevelComponent.text = "Lvl. $level";
    }

    final xpRequired = _playground.worker.experienceNeeded;
    if (_experienceRequired != xpRequired) {
      _experienceRequired = xpRequired.toDouble();
    }

    final resource = _playground.worker.experience;
    if (_resourceAmount != resource) {
      _resourceAmount = resource;
      _workerExperienceComponent.updateStatusBar(
        _resourceAmount ?? 0.0,
        _experienceRequired ?? 0.0,
        alwaysVisible: true,
      );
    }
  }

  void _updateSceneSwitchLock(WorkerModel worker) {
    final recoveryHealth = worker.maxHealth * _sceneSwitchRecoveryHealthPercent;

    if (worker.health <= 0) {
      _switchScenesLockedUntilRecovered = true;
    } else if (_switchScenesLockedUntilRecovered &&
        worker.health >= recoveryHealth) {
      _switchScenesLockedUntilRecovered = false;
    }

    _updateSwitchSceneButtons();
  }

  void _startSceneTransition(int playgroundId, int sceneId) {
    if (_isSceneTransitioning || sceneId == _activeSceneId) {
      return;
    }

    resetEncounterHealth(sceneId);
    _isSceneTransitioning = true;
    _sceneTransitionElapsed = 0;
    _sceneTransitionTargetId = sceneId;
    _setSceneFadeOpacity(0);
    _updateSwitchSceneButtons();
  }

  void _updateSceneTransition(double dt) {
    if (!_isSceneTransitioning) {
      return;
    }

    _sceneTransitionElapsed += dt;

    final halfDuration = _sceneTransitionDuration / 2;
    final targetSceneId = _sceneTransitionTargetId;

    if (_sceneTransitionElapsed < halfDuration) {
      _setSceneFadeOpacity(_sceneTransitionElapsed / halfDuration);
      return;
    }

    if (targetSceneId != null) {
      game.gameStateNotifier.switchActiveScene(_playground.id, targetSceneId);
      _sceneTransitionTargetId = null;
    }

    final fadeOutProgress =
        ((_sceneTransitionElapsed - halfDuration) / halfDuration).clamp(
          0.0,
          1.0,
        );
    _setSceneFadeOpacity(1 - fadeOutProgress);

    if (_sceneTransitionElapsed >= _sceneTransitionDuration) {
      _isSceneTransitioning = false;
      _sceneTransitionElapsed = 0;
      _setSceneFadeOpacity(0);
      _updateSwitchSceneButtons();
    }
  }

  void _setSceneFadeOpacity(double opacity) {
    _sceneFadeComponent.paint = Paint()
      ..color = Colors.black.withOpacity(opacity.clamp(0.0, 1.0));
  }

  void _handleWorkerDefeated() {
    if (_isDefeatTransitioning) {
      return;
    }

    resetEncounters();

    final playground = game.gameStateNotifier.getPlaygroundById(_playground.id);
    final restScene = playground.scenes.whereType<RestSceneModel>().firstOrNull;

    if (restScene == null) {
      return;
    }

    _isDefeatTransitioning = true;
    _defeatTransitionElapsed = 0;
    _defeatRestSceneId = restScene.id;
    _setDefeatFadeOpacity(0);
    _updateSwitchSceneButtons();
  }

  void _updateDefeatTransition(double dt) {
    if (!_isDefeatTransitioning) {
      return;
    }

    _defeatTransitionElapsed += dt;

    final halfDuration = _sceneTransitionDuration / 2;
    final restSceneId = _defeatRestSceneId;

    if (_defeatTransitionElapsed < halfDuration) {
      _setDefeatFadeOpacity(_defeatTransitionElapsed / halfDuration);
      return;
    }

    if (restSceneId != null) {
      game.gameStateNotifier.switchActiveScene(_playground.id, restSceneId);
      _defeatRestSceneId = null;
    }

    final fadeOutProgress =
        ((_defeatTransitionElapsed - halfDuration) / halfDuration).clamp(
          0.0,
          1.0,
        );
    _setDefeatFadeOpacity(1 - fadeOutProgress);

    if (_defeatTransitionElapsed >= _sceneTransitionDuration) {
      _isDefeatTransitioning = false;
      _defeatTransitionElapsed = 0;
      _setDefeatFadeOpacity(0);
      _updateSwitchSceneButtons();
    }
  }

  void _setDefeatFadeOpacity(double opacity) {
    _defeatFadeComponent.paint = Paint()
      ..color = Colors.red.withOpacity(opacity.clamp(0.0, 1.0));
  }

  void _updateSwitchSceneButtons() {
    for (final buttonEntry in _switchSceneButtons.entries) {
      buttonEntry.value.isDisabled =
          _switchScenesLockedUntilRecovered ||
          buttonEntry.key == _activeSceneId;
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
    _sceneFadeComponent.size = size.clone();
    _defeatFadeComponent.size = size.clone();
  }

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

    if (scene is RestSceneModel) {
      return;
    }

    if (scene is EncounterSceneModel) {
      final defaultSpawnX = width + (_padding * 2);
      final encounterWidth = _encounterRadius * 2;

      var hasEncounters = false;
      var maxEncounterX = double.negativeInfinity;

      for (final encounter in children.whereType<EncounterComponent>().where(
        (encounter) => encounter.sceneModel.id == scene.id,
      )) {
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
  }

  void resetEncounters() {
    for (final encounter in children.whereType<EncounterComponent>().toList()) {
      encounter.removeFromParent();
    }
  }

  void resetEncounterHealth(int sceneId) {
    for (final encounter in children.whereType<EncounterComponent>().where(
      (encounter) => encounter.sceneModel.id != sceneId,
    )) {
      encounter.resetHealth();
    }
  }

  void moveOnClick() {
    final playground = game.gameStateNotifier.getPlaygroundById(_playground.id);
    final scene = playground.activeScene;

    if (scene is RestSceneModel) {
      RestSceneModel restingSpotModel = scene;
      playground.worker.restoreHealth(
        restingSpotModel.generationRatePerSecond *
            restingSpotModel.healthRegenPerSecond,
      );
      playground.worker.restoreStamina(
        restingSpotModel.generationRatePerSecond *
            restingSpotModel.staminaRegenPerSecond,
      );
    } else if (scene is EncounterSceneModel) {
      encounterTimer += scene.encounterInterval / 10;

      for (final encounter in children.whereType<EncounterComponent>().where(
        (encounter) => encounter.sceneModel.id == scene.id,
      )) {
        encounter.moveOnClick();
      }
    }
  }

  void addResource() {
    final scene = _playground.activeScene;
    game.gameStateNotifier.add(scene.upgradeCostType, 1.0);
  }

  void subtractResource() {
    final scene = _playground.activeScene;
    game.gameStateNotifier.subtract(scene.upgradeCostType, 1.0);
  }

  void resetResource() {
    final scene = _playground.activeScene;
    game.gameStateNotifier.resetResource(scene.upgradeCostType);
  }
}
