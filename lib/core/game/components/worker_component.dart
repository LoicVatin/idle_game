import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/status_bar_component.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/core/game/components/encounter_component.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/data/models/worker_model.dart';

class WorkerComponent extends RectangleComponent
    with HasGameReference<IdleGame>, CollisionCallbacks {
  final PlaygroundModel playgroundModel;
  final WorkerModel workerModel;
  final VoidCallback? onDefeated;
  bool isAttacking = false;
  double attackTimer = 0;

  static const double _attackDuration = 0.15;
  static const double _confrontationAttackInterval = 0.35;

  EncounterComponent? confrontationTarget;
  double confrontationAttackTimer = 0;

  double _lastHealth = -1;
  double _lastStamina = -1;
  int? _lastHealthSceneId;
  int? _lastStaminaSceneId;
  bool? _lastHealthAlwaysVisible;
  bool? _lastStaminaAlwaysVisible;

  late final StatusBarComponent healthBar;
  late final StatusBarComponent staminaBar;

  WorkerComponent({
    required this.playgroundModel,
    required this.workerModel,
    this.onDefeated,
    double radius = 24,
    super.position,
    super.anchor,
    super.priority = 50,
  }) : super(
         size: Vector2.all(radius * 2),
         paint: Paint()..color = Colors.blueAccent,
         children: [
           StatusBarComponent(
             position: Vector2(
               radius - (StatusBarComponent.statusBarWidth / 2),
               -(StatusBarComponent.statusBarHeight * 2) -
                   StatusBarComponent.statusBarGap -
                   4,
             ),
             fillColor: Colors.greenAccent,
           ),
           StatusBarComponent(
             position: Vector2(
               radius - (StatusBarComponent.statusBarWidth / 2),
               -StatusBarComponent.statusBarHeight - 4,
             ),
             fillColor: Colors.orangeAccent,
           ),
           IconComponent(
             icon: workerModel.icon,
             size: Vector2.all(radius),
             anchor: Anchor.bottomRight,
             position: Vector2.all(radius),
           ),
           IconComponent(
             icon: workerModel.toolsIcon,
             size: Vector2.all(radius),
             anchor: Anchor.topLeft,
             position: Vector2.all(radius),
           ),
         ],
       ) {
    final statusBars = children.whereType<StatusBarComponent>().toList();

    healthBar = statusBars[0];
    staminaBar = statusBars[1];
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());
    updateHealthBar();
    updateStaminaBar();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isAttacking) {
      attackTimer -= dt;

      if (attackTimer <= 0) {
        isAttacking = false;
        paint.color = Colors.blueAccent;
      }
    }

    updateHealthBar();
    updateStaminaBar();
    updateConfrontation(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is EncounterComponent) {
      startConfrontation(other);
    }
  }

  void attack() {
    if (!workerModel.spendAttackStamina()) {
      return;
    }
    isAttacking = true;
    attackTimer = _attackDuration;
    paint.color = Colors.yellow;
    updateStaminaBar();
  }

  void updateHealthBar() {
    final scene = playgroundModel.activeScene;
    final alwaysVisible = scene is RestSceneModel;

    if (_lastHealth == workerModel.health &&
        _lastHealthSceneId == scene.id &&
        _lastHealthAlwaysVisible == alwaysVisible) {
      return;
    }
    _lastHealth = workerModel.health;
    _lastHealthSceneId = scene.id;
    _lastHealthAlwaysVisible = alwaysVisible;

    healthBar.updateStatusBar(
      workerModel.health,
      workerModel.maxHealth,
      alwaysVisible: alwaysVisible,
    );
  }

  void updateStaminaBar() {
    final scene = playgroundModel.activeScene;
    final alwaysVisible = scene is RestSceneModel;

    if (_lastStamina == workerModel.stamina &&
        _lastStaminaSceneId == scene.id &&
        _lastStaminaAlwaysVisible == alwaysVisible) {
      return;
    }
    _lastStamina = workerModel.stamina;
    _lastStaminaSceneId = scene.id;
    _lastStaminaAlwaysVisible = alwaysVisible;

    staminaBar.updateStatusBar(
      workerModel.stamina,
      workerModel.maxStamina,
      alwaysVisible: alwaysVisible,
    );
  }

  void updateConfrontation(double dt) {
    final target = confrontationTarget;

    if (target == null || target.isRemoved) {
      endConfrontation();
      return;
    }

    final scene = playgroundModel.activeScene;
    if (scene is RestSceneModel ||
        (scene is EncounterSceneModel && !scene.encounter)) {
      return;
    }

    confrontationAttackTimer -= dt;

    if (confrontationAttackTimer > 0) {
      return;
    }

    if (!workerModel.canAttack || !workerModel.isAlive) {
      return;
    }

    confrontationAttackTimer = _confrontationAttackInterval;
    attack();

    final defeated = target.takeDamage(workerModel.damage);
    workerModel.takeDamage(target.encounterModel.damage);
    updateHealthBar();

    if (!workerModel.isAlive) {
      endConfrontation();
      workerModel.resetExperience();
      onDefeated?.call();
      switchToRestingScene();
      return;
    }

    if (defeated) {
      target.defeat();
      endConfrontation();
    }
  }

  void startConfrontation(EncounterComponent enemy) {
    if (confrontationTarget == enemy) {
      return;
    }

    confrontationTarget = enemy;
    confrontationAttackTimer = 0;
    Future<void>(() {
      if (isRemoved) return;

      game.gameStateNotifier.toggleEncounter(
        playgroundModel.activeSceneId,
        true,
      );
    });
  }

  void endConfrontation() {
    confrontationTarget = null;
    confrontationAttackTimer = 0;
    game.gameStateNotifier.toggleEncounter(
      playgroundModel.activeSceneId,
      false,
    );
  }

  void switchToRestingScene() {
    final playground = game.gameStateNotifier.getPlaygroundById(
      playgroundModel.id,
    );
    final restingScene = playground.scenes
        .whereType<RestSceneModel>()
        .firstOrNull;

    if (restingScene == null) {
      return;
    }

    game.gameStateNotifier.switchActiveScene(playground.id, restingScene.id);
  }
}
