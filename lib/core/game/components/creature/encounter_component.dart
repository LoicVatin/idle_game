import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/component_utils.dart';
import 'package:idle_game/core/game/components/creature/creature_component.dart';
import 'package:idle_game/data/models/creature/creature_state.dart';
import 'package:idle_game/core/game/components/creature/worker_component.dart';
import 'package:idle_game/data/models/creature/creature_model.dart';
import 'package:idle_game/data/models/creature/encounter_model.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';

class EncounterComponent extends CreatureComponent<EncounterModel> {
  @override
  EncounterSceneModel scene;

  @override
  String get defaultSpriteSheetFolder => "encounters/";

  @override
  String get defaultSpriteSheet => "encounter";

  EncounterComponent({
    required this.scene,
    required super.model,
    super.collisionType = CollisionType.passive,
    super.position,
    super.anchor,
    super.color = Colors.pinkAccent,
    super.statusOrder = StatusOrder.staminaStatusHealth,
    super.primaryIconAnchor = Anchor.topRight,
    super.secondaryIconAnchor = Anchor.bottomLeft,
    super.priority = Priorities.high,
  }) : super() {
    paint.color = model.type.color.withValues(alpha: 0.3);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!scene.active) {
      return;
    }

    if (!model.isAlive) {
      removeFromParent();
      return;
    }

    updateCreatureState(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is WorkerComponent) {
      game.gameStateNotifier.startConfrontation(scene.playgroundId, model);
      onConfrontation();
    }
  }

  void resetHealth() {
    model.health = model.maxHealth;
    isInConfrontation = false;
    state = CreatureState.idle;
    timer = 0;
    paint.color = model.type.color.withValues(alpha: 0.3);
    updateHealthBar();
  }

  // Creature overrides
  @override
  void updateCreatureState(double dt) {
    super.updateCreatureState(dt);

    if (model.health < lastHealth) {
      onConfrontation();
    }
    lastHealth = model.health;

    if (isInConfrontation) {
      timer -= dt;

      if (timer <= 0) {
        isInConfrontation = false;
        paint.color = model.type.color.withValues(alpha: 0.3);
      }
    }

    if (!scene.encounter) {
      final clickVelocity = clickBoostTime > 0
          ? CreatureModel.clickBoostVelocity * 10
          : 0.0;
      final movement = scene.generationRatePerSecond * 10 + clickVelocity;

      x -= movement * dt;

      model.updateState(
        isWorkerDepleted: false,
        isInConfrontationStep: false,
        isMoving: movement > 0,
      );

      if (x < -width) {
        removeFromParent();
      }
    } else {
      clickBoostTime = 0;

      final playground = game.gameStateNotifier.getPlaygroundById(
        scene.playgroundId,
      );

      model.updateState(
        isWorkerDepleted: !playground.worker.canAttack && isInConfrontation,
        isInConfrontationStep: isInConfrontation,
      );

      if (!playground.worker.canAttack) {
        isInConfrontation = false;
        timer = 0;
        paint.color = model.type.color.withValues(alpha: 0.3);
      }
    }

    state = model.state;
  }

  @override
  bool isStatusAlwaysVisible() {
    return true;
  }

  @override
  bool isHealthBarAlwaysVisible() {
    return false;
  }

  @override
  bool isStaminaBarAlwaysVisible() {
    return false;
  }

  @override
  void defeat() {
    game.gameStateNotifier.defeatEncounter(scene.id, model.type, model.reward);
    removeFromParent();
  }
}
