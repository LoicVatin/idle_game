import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/encounter_model.dart';
import 'package:idle_game/data/models/scene_model.dart';

class EncounterComponent extends RectangleComponent
    with HasGameReference<IdleGame>, CollisionCallbacks {
  final double radius;
  SceneModel sceneModel;
  EncounterModel encounterModel;
  late double health;
  bool isAttacked = false;
  double attackedTimer = 0;

  double _clickBoostTime = 0;
  static const double _clickBoostDuration = 0.1;
  static const double _clickBoostVelocity = 60;
  static const double _attackedDuration = 0.15;

  EncounterComponent({
    required this.sceneModel,
    required this.encounterModel,
    this.radius = 24,
    super.position,
    super.anchor,
  }) : health = encounterModel.health,
       super(
         size: Vector2.all(radius * 2),
         paint: Paint()..color = encounterModel.type.color,
         children: [
           IconComponent(
             icon: encounterModel.type.icon,
             size: Vector2.all(radius),
             anchor: Anchor.bottomLeft,
             position: Vector2.all(radius),
           ),
           IconComponent(
             icon: encounterModel.icon,
             size: Vector2.all(radius),
             anchor: Anchor.topRight,
             position: Vector2.all(radius),
           ),
         ],
       );

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    if (isAttacked) {
      attackedTimer -= dt;

      if (attackedTimer <= 0) {
        isAttacked = false;
        paint.color = encounterModel.type.color;
      }
    }

    final scene = game.gameStateNotifier.getSceneById(
      sceneModel.id,
    );
    if (!scene.encounter) {
      if (_clickBoostTime > 0) {
        _clickBoostTime -= dt;
      }

      final clickVelocity = _clickBoostTime > 0 ? _clickBoostVelocity : 0.0;
      final movement = scene.generationRatePerSecond * 10 + clickVelocity;

      x -= movement * dt;

      if (x < -width) {
        removeFromParent();
      }
    }

    super.update(dt);
  }

  bool takeDamage(double amount) {
    health -= amount;
    isAttacked = true;
    attackedTimer = _attackedDuration;
    paint.color = Colors.orange;

    return health <= 0;
  }

  void moveOnClick() {
    _clickBoostTime = _clickBoostDuration;
  }

  void defeat() {
    game.gameStateNotifier.defeatEncounter(
      sceneModel.id,
      encounterModel.type,
      encounterModel.reward,
    );
    removeFromParent();
  }
}
