import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/creature/creature_component.dart';
import 'package:idle_game/core/game/components/creature/sprite_animation_with_states_component.dart';
import 'package:idle_game/core/game/components/creature/worker_component.dart';
import 'package:idle_game/data/models/creature/encounter_model.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';

class EncounterComponent extends CreatureComponent<EncounterModel> {
  @override
  EncounterSceneModel scene;
  bool isSceneActive = true;

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
  }) : super() {
    paint.color = model.type.color.withValues(alpha: 0.3);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!scene.active) {
      return;
    }

    updateStatusText();
    updateHealthBar();
    updateStaminaBar();

    if (isInConfrontation) {
      timer -= dt;

      if (timer <= 0) {
        isInConfrontation = false;
        paint.color = model.type.color.withValues(alpha: 0.3);
      }
    }

    if (!scene.encounter) {
      if (clickBoostTime > 0) {
        clickBoostTime -= dt;
      }

      final clickVelocity = clickBoostTime > 0
          ? CreatureComponent.clickBoostVelocity
          : 0.0;
      final movement = scene.generationRatePerSecond * 10 + clickVelocity;

      x -= movement * dt;

      if (x < -width) {
        removeFromParent();
      }
    } else {
      clickBoostTime = 0;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is WorkerComponent) {
      scene.encounter = true;
    }
  }

  bool takeDamage(double amount) {
    model.takeDamage(amount);
    isInConfrontation = true;
    spriteAnimationComponent.state = AnimationState.attack;

    timer = CreatureComponent.confrontationStepDuration;
    paint.color = Colors.orange.withValues(alpha: 0.3);
    updateHealthBar();

    return model.health <= 0;
  }

  void pauseConfrontation() {
    spriteAnimationComponent.state = AnimationState.idle;
  }

  void resetHealth() {
    model.health = model.maxHealth;
    isInConfrontation = false;
    spriteAnimationComponent.state = AnimationState.idle;
    timer = 0;
    paint.color = model.type.color.withValues(alpha: 0.3);
    updateHealthBar();
  }

  // Creature overrides

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
  void moveOnClick() {
    clickBoostTime = CreatureComponent.clickBoostDuration;
  }

  @override
  void defeat() {
    game.gameStateNotifier.defeatEncounter(scene.id, model.type, model.reward);
    removeFromParent();
  }
}
