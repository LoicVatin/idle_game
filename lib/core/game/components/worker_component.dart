import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/core/game/components/encounter_component.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/resting_spot_model.dart';
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
  static const double _statusBarWidth = 42;
  static const double _statusBarHeight = 5;
  static const double _statusBarGap = 3;

  late final RectangleComponent healthBarBackground;
  late final RectangleComponent healthBarFill;
  late final RectangleComponent staminaBarBackground;
  late final RectangleComponent staminaBarFill;

  WorkerComponent({
    required this.playgroundModel,
    required this.workerModel,
    this.onDefeated,
    double radius = 24,
    super.position,
    super.anchor,
    super.priority = 50
  }) : super(
         size: Vector2.all(radius * 2),
         paint: Paint()..color = Colors.blueAccent,
         children: [
           RectangleComponent(
             size: Vector2(_statusBarWidth, _statusBarHeight),
             position: Vector2(
               radius - (_statusBarWidth / 2),
               -(_statusBarHeight * 2) - _statusBarGap - 4,
             ),
             paint: Paint()..color = Colors.black54,
           ),
           RectangleComponent(
             size: Vector2(_statusBarWidth, _statusBarHeight),
             position: Vector2(
               radius - (_statusBarWidth / 2),
               -(_statusBarHeight * 2) - _statusBarGap - 4,
             ),
             paint: Paint()..color = Colors.greenAccent,
           ),
           RectangleComponent(
             size: Vector2(_statusBarWidth, _statusBarHeight),
             position: Vector2(
               radius - (_statusBarWidth / 2),
               -_statusBarHeight - 4,
             ),
             paint: Paint()..color = Colors.black54,
           ),
           RectangleComponent(
             size: Vector2(_statusBarWidth, _statusBarHeight),
             position: Vector2(
               radius - (_statusBarWidth / 2),
               -_statusBarHeight - 4,
             ),
             paint: Paint()..color = Colors.orangeAccent,
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
    final statusBars = children.whereType<RectangleComponent>().toList();

    healthBarBackground = statusBars[0];
    healthBarFill = statusBars[1];
    staminaBarBackground = statusBars[2];
    staminaBarFill = statusBars[3];
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
    final healthPercent = workerModel.maxHealth <= 0
        ? 0.0
        : (workerModel.health / workerModel.maxHealth).clamp(0.0, 1.0);

    healthBarFill.size.x = _statusBarWidth * healthPercent;
  }

  void updateStaminaBar() {
    final staminaPercent = workerModel.maxStamina <= 0
        ? 0.0
        : (workerModel.stamina / workerModel.maxStamina).clamp(0.0, 1.0);

    staminaBarFill.size.x = _statusBarWidth * staminaPercent;
  }

  void updateConfrontation(double dt) {
    final target = confrontationTarget;

    if (target == null || target.isRemoved) {
      endConfrontation();
      return;
    }

    final scene = game.gameStateNotifier.getPlaygroundById(playgroundModel.id).activeScene;
    if (!scene.encounter) {
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

      game.gameStateNotifier.toggleEncounter(game.gameStateNotifier.getPlaygroundById(playgroundModel.id).activeSceneId, true);
    });
  }

  void endConfrontation() {
    confrontationTarget = null;
    confrontationAttackTimer = 0;
    game.gameStateNotifier.toggleEncounter(game.gameStateNotifier.getPlaygroundById(playgroundModel.id).activeSceneId, false);
  }

  void switchToRestingScene() {
    final playground = game.gameStateNotifier.getPlaygroundById(playgroundModel.id);
    final restingScene = playground.scenes.whereType<RestingSpotModel>().firstOrNull;

    if (restingScene == null) {
      return;
    }

    game.gameStateNotifier.switchActiveScene(playground.id, restingScene.id);
  }
}
