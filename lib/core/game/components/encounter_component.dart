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
  static const double _healthBarWidth = 42;
  static const double _healthBarHeight = 5;

  late final RectangleComponent healthBarBackground;
  late final RectangleComponent healthBarFill;

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
           RectangleComponent(
             size: Vector2(_healthBarWidth, _healthBarHeight),
             position: Vector2(
               radius - (_healthBarWidth / 2),
               -_healthBarHeight - 4,
             ),
             paint: Paint()..color = Colors.black54,
           ),
           RectangleComponent(
             size: Vector2(_healthBarWidth, _healthBarHeight),
             position: Vector2(
               radius - (_healthBarWidth / 2),
               -_healthBarHeight - 4,
             ),
             paint: Paint()..color = Colors.greenAccent,
           ),
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
       ) {
    healthBarBackground = children.whereType<RectangleComponent>().first;
    healthBarFill = children.whereType<RectangleComponent>().skip(1).first;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox(collisionType: CollisionType.passive));
    updateHealthBar();
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

    final scene = game.gameStateNotifier.getSceneById(sceneModel.id);
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
    health = (health - amount).clamp(0.0, encounterModel.health);
    isAttacked = true;
    attackedTimer = _attackedDuration;
    paint.color = Colors.orange;
    updateHealthBar();

    return health <= 0;
  }

  void updateHealthBar() {
    final healthPercent = encounterModel.health <= 0
        ? 0.0
        : (health / encounterModel.health).clamp(0.0, 1.0);

    healthBarFill.size.x = _healthBarWidth * healthPercent;
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
