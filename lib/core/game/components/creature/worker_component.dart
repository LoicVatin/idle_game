import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/creature/creature_component.dart';
import 'package:idle_game/core/game/components/creature/sprite_animation_with_states_component.dart';
import 'package:idle_game/core/game/components/creature/encounter_component.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/creature/worker_model.dart';

class WorkerComponent extends CreatureComponent<WorkerModel> {
  final PlaygroundModel playgroundModel;
  final VoidCallback? onDefeated;

  EncounterComponent? confrontationTarget;
  double confrontationAttackTimer = 0;

  WorkerComponent({
    required this.playgroundModel,
    required super.model,
    required this.onDefeated,
    super.position,
    super.anchor,
    super.color = Colors.blueAccent,
    super.statusOrder = StatusOrder.statusHealthStamina,
    super.primaryIconAnchor = Anchor.bottomRight,
    super.secondaryIconAnchor = Anchor.topLeft,
  }) : super();

  @override
  void update(double dt) {
    super.update(dt);

    if (isInConfrontation) {
      timer -= dt;

      if (timer <= 0) {
        isInConfrontation = false;
        paint.color = Colors.blueAccent;
      }
    }

    updateStatusText();
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
      spriteAnimationComponent.state = AnimationState.attack;
      startConfrontation(other);
    }
  }

  void attack() {
    if (!model.spendAttackStamina()) {
      spriteAnimationComponent.state = AnimationState.depleted;
      return;
    }
    isInConfrontation = true;
    timer = CreatureComponent.confrontationStepDuration;
    paint.color = Colors.yellow;
    updateStaminaBar();
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

  void updateConfrontation(double dt) {
    final scene = playgroundModel.activeScene;
    if (scene is RestSceneModel) {
      spriteAnimationComponent.state = AnimationState.rest;
      return;
    }

    if ((scene is EncounterSceneModel && !scene.encounter)) {
      if (clickBoostTime > 0) {
        clickBoostTime -= dt;
      }

      spriteAnimationComponent.state =
          (scene.generationRatePerSecond > 0 || clickBoostTime > 0)
          ? AnimationState.walk
          : AnimationState.idle;
      return;
    }

    final target = confrontationTarget;

    if (target == null || target.isRemoved) {
      defeat();
      return;
    }

    confrontationAttackTimer -= dt;

    if (confrontationAttackTimer > 0) {
      return;
    }

    if (!model.canAttack) {
      spriteAnimationComponent.state = AnimationState.depleted;
      return;
    }
    if (!model.isAlive) {
      return;
    }

    confrontationAttackTimer = CreatureComponent.confrontationAttackInterval;
    attack();

    final defeated = target.takeDamage(model.damage);
    model.takeDamage(target.model.damage);
    updateHealthBar();

    if (!model.isAlive) {
      spriteAnimationComponent.state = AnimationState.defeat;
      defeat();
      model.resetExperience();
      onDefeated?.call();
      switchToRestingScene();
      return;
    }

    if (defeated) {
      target.defeat();
      defeat();
    }
  }

  void switchToRestingScene() {
    final playground = game.gameStateNotifier.getPlaygroundById(
      playgroundModel.id,
    );
    final restingScene = playground.thirdScene;

    game.gameStateNotifier.switchActiveScene(playground.id, restingScene.id);
    spriteAnimationComponent.state = AnimationState.rest;
  }

  // Creature overrides

  @override
  SceneModel get scene => playgroundModel.activeScene;

  @override
  bool isStatusAlwaysVisible() {
    //final scene = playgroundModel.activeScene;
    //return scene is RestSceneModel;
    return false;
  }

  @override
  bool isHealthBarAlwaysVisible() {
    final scene = playgroundModel.activeScene;
    return scene is RestSceneModel;
  }

  @override
  bool isStaminaBarAlwaysVisible() {
    final scene = playgroundModel.activeScene;
    return scene is RestSceneModel;
  }

  @override
  void moveOnClick() {
    clickBoostTime = CreatureComponent.clickBoostDuration;
  }

  @override
  void defeat() {
    spriteAnimationComponent.state = AnimationState.idle;
    confrontationTarget = null;
    confrontationAttackTimer = 0;
    game.gameStateNotifier.toggleEncounter(
      playgroundModel.activeSceneId,
      false,
    );
  }
}
