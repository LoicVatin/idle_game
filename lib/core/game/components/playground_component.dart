import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
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
import 'package:idle_game/utils/build_context_helper.dart';

class PlaygroundComponent extends RectangleComponent
    with HasGameReference<IdleGame>, TapCallbacks, HasVisibility {
  final PlaygroundModel _playground;
  double encounterTimer = 0;
  static const double _padding = 10.0;
  static const double _encounterRadius = 24.0;
  static const double _height = 200.0;
  static const double _sceneSwitchRecoveryHealthPercent = 0.25;
  static const double _sceneTransitionDuration = 0.4;

  PlaygroundComponent({required PlaygroundModel playground})
    : _playground = playground;

  late ColumnComponent headerComponent;
  late RectangleComponent _borderComponent;
  RectangleComponent switchSceneComponent = RectangleComponent();
  late RectangleComponent _sceneFadeComponent;
  late RectangleComponent _defeatFadeComponent;
  final Map<int, RectangleButtonComponent> switchSceneButtons = {};
  bool _switchScenesLockedUntilRecovered = false;
  bool _isSceneTransitioning = false;
  double _sceneTransitionElapsed = 0;
  int? _sceneTransitionTargetId;
  bool _isDefeatTransitioning = false;
  double _defeatTransitionElapsed = 0;
  int? _defeatRestSceneId;

  late TextComponent _nameComponent;
  late TextComponent rateComponent;

  late RectangleButtonComponent upgradeButton;

  late WorkerComponent workerComponent;
  late TextComponent _workerLevelComponent;
  late StatusBarComponent _workerExperienceComponent;

  StreamSubscription? _subscription;

  @override
  void onMount() {
    super.onMount();
    _subscription = game.gameStateNotifier.onUpdate.listen(
      (_) => _updateState(),
    );
    _updateState();
  }

  @override
  void onRemove() {
    _subscription?.cancel();
    super.onRemove();
  }

  void _updateState() {
    final scene = _playground.activeScene;

    _updateSceneSwitchLock(_playground.worker);
    _updateScene(scene);
  }

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

    _nameComponent = TextComponent(
      text: _lastSceneName,
      textRenderer: TextPaint(style: game.textTheme.titleLarge),
    );

    _workerLevelComponent = TextComponent(
      text: game.text.worker_level_indicator(_currentLevel ?? 1),
      textRenderer: TextPaint(style: game.textTheme.bodyMedium),
    );

    _workerExperienceComponent = StatusBarComponent();

    rateComponent = TextComponent(
      anchor: Anchor.bottomRight,
      text: _lastRateText,
      position: Vector2(width - _padding - 24 * 2, height - _padding),
      priority: 10,
      textRenderer: TextPaint(style: game.textTheme.titleLarge),
    );

    headerComponent = ColumnComponent(
      position: Vector2.all(_padding),
      children: [
        _nameComponent,
        _workerLevelComponent,
        _workerExperienceComponent,
      ],
      priority: 10,
    );

    add(headerComponent);
    add(rateComponent);

    workerComponent = WorkerComponent(
      playgroundModel: _playground,
      workerModel: _playground.worker,
      position: Vector2(_padding, height - _padding),
      anchor: Anchor.bottomLeft,
      onDefeated: _handleWorkerDefeated,
    );
    add(workerComponent);

    _borderComponent = RectangleComponent(
      size: size.clone(),
      paint: Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      priority: 100,
    );
    add(_borderComponent);

    upgradeButton = RectangleButtonComponent(
      icon: Icons.settings,
      onPressed: () {
        game.displayUpgradeOverlay(playground.id);
      },
    );

    switchSceneComponent
      ..paint = (Paint()
        ..color = Colors.black
        ..strokeWidth = 2)
      ..size = Vector2((24 * 2) + 4, height)
      ..anchor = Anchor.topRight
      ..position = Vector2(width, 0)
      ..priority = 100
      ..addAll([
        ColumnComponent(
          size: Vector2((24 * 2) + 4, height),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              switchSceneButtons[scene.id] = button;
              return button;
            }),
            upgradeButton,
          ],
        ),
      ]);
    add(switchSceneComponent);

    _sceneFadeComponent = RectangleComponent(
      size: size.clone(),
      paint: Paint()..color = Colors.black.withValues(alpha: 0.0),
      priority: 25,
    );
    add(_sceneFadeComponent);

    _defeatFadeComponent = RectangleComponent(
      size: size.clone(),
      paint: Paint()..color = Colors.red.withValues(alpha: 0.0),
      priority: 75,
    );
    add(_defeatFadeComponent);

    _updateResponsivePositions(force: true);
  }

  @override
  void update(double dt) {
    final scene = _playground.activeScene;

    _updateSceneTransition(dt);
    _updateDefeatTransition(dt);
    _updateSceneSwitchLock(_playground.worker);
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

    super.update(dt);
  }

  void _updateScene(SceneModel scene) {
    final sceneId = scene.id;
    if (_activeSceneId != sceneId) {
      paint = Paint()..color = scene.backgroundColor;
      _activeSceneId = sceneId;

      _updateSwitchSceneButtons();
      for (final buttonEntry in switchSceneButtons.entries) {
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
      rateComponent.text = rateText;
    }

    final level = _playground.worker.level;
    if (_currentLevel != level) {
      _currentLevel = level;
      _workerLevelComponent.text = game.text.worker_level_indicator(level);
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
      ..color = Colors.black.withValues(alpha: opacity.clamp(0.0, 1.0));
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
      ..color = Colors.red.withValues(alpha: opacity.clamp(0.0, 1.0));
  }

  void _updateSwitchSceneButtons() {
    for (final buttonEntry in switchSceneButtons.entries) {
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

    rateComponent.position.setValues(
      width - _padding - 24 * 2,
      height - _padding,
    );
    workerComponent.position.setValues(_padding, height - _padding);
    _borderComponent.size.setFrom(size.clone());
    switchSceneComponent.position.setValues(width, 0);
    _sceneFadeComponent.size.setFrom(size.clone());
    _defeatFadeComponent.size.setFrom(size.clone());
  }

  String _formatRate(double rate) =>
      '(${game.text.per_second_indicator(rate.toStringAsPrecision(3))})';

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    moveOnClick();
  }

  void generateEncounter([SceneModel? cachedScene]) {
    final scene =
        cachedScene ??
        game.gameStateNotifier.getPlaygroundById(_playground.id).activeScene;

    if (scene is! EncounterSceneModel) {
      return;
    }

    final encounterWidth = _encounterRadius * 2;
    final defaultSpawnX = width - encounterWidth;
    var maxEncounterX = double.negativeInfinity;

    for (final child in children) {
      if (child is! EncounterComponent || child.sceneModel.id != scene.id) {
        continue;
      }

      if (child.x - encounterWidth > width) {
        return;
      }

      if (child.x > maxEncounterX) {
        maxEncounterX = child.x;
      }
    }

    final hasEncounters = maxEncounterX.isFinite;
    final spawnX = hasEncounters
        ? maxEncounterX + encounterWidth + scene.encounterSpacing
        : defaultSpawnX;

    if (spawnX > defaultSpawnX) {
      return;
    }

    add(
      EncounterComponent(
        sceneModel: scene,
        encounterModel: scene.encounters.getNext(),
        radius: _encounterRadius,
        position: Vector2(spawnX, height - _padding),
        anchor: Anchor.bottomLeft,
      ),
    );
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
}
