import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/rectangle_button_component.dart';
import 'package:idle_game/core/game/components/creature/status_bar_component.dart';
import 'package:idle_game/core/game/components/scene/encounter_scene_component.dart';
import 'package:idle_game/core/game/components/scene/rest_scene_component.dart';
import 'package:idle_game/core/game/components/component_utils.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/core/game/components/creature/worker_component.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/creature/worker_model.dart';
import 'package:idle_game/utils/build_context_helper.dart';

class PlaygroundComponent extends RectangleComponent
    with HasGameReference<IdleGame>, TapCallbacks, HasVisibility {
  final PlaygroundModel _playground;
  static final double _padding = Dimensions.extraSmall;
  static const double _height = Dimensions.gigantic;
  static const double _sceneSwitchRecoveryHealthPercent = 0.25;
  static const double _sceneTransitionDuration = 0.4;

  PlaygroundComponent({required PlaygroundModel playground})
    : _playground = playground;

  late ColumnComponent headerComponent;
  late RectangleComponent _borderComponent;
  RectangleComponent switchSceneComponent = RectangleComponent();
  late RectangleComponent _sceneFadeComponent;
  late RectangleComponent _defeatFadeComponent;
  late RectangleButtonComponent firstSwitchButton;
  late RectangleButtonComponent secondSwitchButton;
  late RectangleButtonComponent thirdSwitchButton;
  bool _switchScenesLockedUntilRecovered = false;
  bool _isSceneTransitioning = false;
  double _sceneTransitionElapsed = 0;
  int? _sceneTransitionTargetId;
  bool _isDefeatTransitioning = false;
  double _defeatTransitionElapsed = 0;
  int? _defeatRestSceneId;

  late RectangleButtonComponent upgradeButton;

  late WorkerComponent workerComponent;
  late TextComponent _workerLevelComponent;
  late StatusBarComponent _workerExperienceComponent;
  late EncounterSceneComponent firstScene;
  late EncounterSceneComponent secondScene;
  late RestSceneComponent thirdScene;

  StreamSubscription? _subscription;
  StreamSubscription? _defeatSubscription;

  @override
  void onMount() {
    super.onMount();
    _subscription = game.gameStateNotifier.onUpdate.listen(
      (_) => _updateState(),
    );
    _defeatSubscription = game.gameStateNotifier.onWorkerDefeated.listen((
      playgroundId,
    ) {
      if (playgroundId == _playground.id) handleWorkerDefeated();
    });
    _updateState();
  }

  @override
  void onRemove() {
    _subscription?.cancel();
    _defeatSubscription?.cancel();
    super.onRemove();
  }

  void _updateState() {
    final scene = _playground.activeScene;

    _updateSceneSwitchLock(_playground.worker);
    _updateScene(scene);
  }

  Vector2? _lastSize;
  double? _resourceAmount;
  double? _experienceRequired;
  int? _currentLevel;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2.all(_height);
    final playground = game.gameStateNotifier.getPlaygroundById(_playground.id);

    paint = Paint()..color = Colors.black;

    _currentLevel = playground.worker.level;

    _workerLevelComponent = TextComponent(
      text: game.text.worker_level_indicator(_currentLevel ?? 1),
      textRenderer: TextPaint(style: game.textTheme.bodyMedium),
    );

    _workerExperienceComponent = StatusBarComponent();

    headerComponent = ColumnComponent(
      position: Vector2.all(_padding),
      children: [
        TextComponent(
          textRenderer: TextPaint(style: game.textTheme.titleLarge),
        ),
        _workerLevelComponent,
        _workerExperienceComponent,
      ],
      priority: 10,
    );

    add(headerComponent);

    workerComponent = WorkerComponent(
      playgroundModel: _playground,
      model: _playground.worker,
      position: Vector2(_padding, height - _padding),
      anchor: Anchor.bottomLeft,
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

    firstSwitchButton =
        RectangleButtonComponent(
            icon: playground.firstScene.icon,
            onPressed: () {
              _startSceneTransition(playground.id, playground.firstScene.id);
            },
          )
          ..isDisabled =
              (playground.firstScene.active &&
              _switchScenesLockedUntilRecovered);

    secondSwitchButton =
        RectangleButtonComponent(
            icon: playground.secondScene.icon,
            onPressed: () {
              _startSceneTransition(playground.id, playground.secondScene.id);
            },
          )
          ..isDisabled =
              (playground.secondScene.active &&
              _switchScenesLockedUntilRecovered);

    thirdSwitchButton =
        RectangleButtonComponent(
            icon: playground.thirdScene.icon,
            onPressed: () {
              _startSceneTransition(playground.id, playground.thirdScene.id);
            },
          )
          ..isDisabled =
              (playground.thirdScene.active &&
              _switchScenesLockedUntilRecovered);

    switchSceneComponent
      ..paint = (Paint()
        ..color = Colors.black
        ..strokeWidth = 2)
      ..size = Vector2((Dimensions.medium * 2) + 4, height)
      ..anchor = Anchor.topRight
      ..position = Vector2(width, 0)
      ..priority = 100
      ..addAll([
        ColumnComponent(
          size: Vector2((Dimensions.medium * 2) + 4, height),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          priority: 100,
          children: [
            firstSwitchButton,
            secondSwitchButton,
            thirdSwitchButton,
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

    firstScene = EncounterSceneComponent(
      size: Vector2(width - ((Dimensions.medium * 2) + 4), height),
      playground: playground,
      scene: playground.firstScene,
      visible: true,
    );
    add(firstScene);

    secondScene = EncounterSceneComponent(
      size: Vector2(width - ((Dimensions.medium * 2) + 4), height),
      playground: playground,
      scene: playground.secondScene,
    );
    add(secondScene);

    thirdScene = RestSceneComponent(
      size: Vector2(width - ((Dimensions.medium * 2) + 4), height),
      playground: playground,
      scene: playground.thirdScene,
    );
    add(thirdScene);

    _updateResponsivePositions(force: true);
  }

  @override
  void update(double dt) {
    _updateSceneTransition(dt);
    _updateDefeatTransition(dt);
    _updateSceneSwitchLock(_playground.worker);
    _updateResponsivePositions();

    super.update(dt);
  }

  void _updateScene(SceneModel scene) {
    _updateSwitchSceneButtons();

    final level = _playground.worker.level;
    if (_currentLevel != level) {
      _currentLevel = level;
      _workerLevelComponent.text = game.text.worker_level_indicator(level);
    }

    final xpRequired = _playground.worker.experienceNeededToLevelUp;
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
    if (_isSceneTransitioning) {
      // || sceneId == _activeSceneId) {
      return;
    }

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

  void handleWorkerDefeated() {
    if (_isDefeatTransitioning) {
      return;
    }

    final playground = game.gameStateNotifier.getPlaygroundById(_playground.id);
    firstScene.resetEncounters();
    secondScene.resetEncounters();
    final restScene = playground.thirdScene;

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
    firstSwitchButton.isDisabled =
        _switchScenesLockedUntilRecovered || _playground.firstScene.active;
    secondSwitchButton.isDisabled =
        _switchScenesLockedUntilRecovered || _playground.secondScene.active;
    thirdSwitchButton.isDisabled =
        _switchScenesLockedUntilRecovered || _playground.thirdScene.active;
  }

  void _updateResponsivePositions({bool force = false}) {
    if (!force && _lastSize?.x == width && _lastSize?.y == height) {
      return;
    }

    _lastSize = size.clone();
    workerComponent.position.setValues(_padding, height - _padding);
    _borderComponent.size.setFrom(size.clone());
    switchSceneComponent.position.setValues(width, 0);
    _sceneFadeComponent.size.setFrom(size.clone());
    _defeatFadeComponent.size.setFrom(size.clone());

    firstScene.size.setFrom(
      Vector2(width - ((Dimensions.medium * 2) + 4), height),
    );
    secondScene.size.setFrom(
      Vector2(width - ((Dimensions.medium * 2) + 4), height),
    );
    thirdScene.size.setFrom(
      Vector2(width - ((Dimensions.medium * 2) + 4), height),
    );
  }
}
