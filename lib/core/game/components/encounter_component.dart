import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/status_bar_component.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/encounter_model.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/scene_model.dart';

class EncounterComponent extends RectangleComponent
    with HasGameReference<IdleGame>, CollisionCallbacks, HasVisibility {
  final double radius;
  SceneModel sceneModel;
  EncounterModel encounterModel;
  late double health;
  bool isAttacked = false;
  double attackedTimer = 0;
  bool isSceneActive = true;

  double _clickBoostTime = 0;
  static const double _clickBoostDuration = 0.1;
  static const double _clickBoostVelocity = 60;
  static const double _attackedDuration = 0.15;

  late final StatusBarComponent healthBar;

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
           StatusBarComponent(
             position: Vector2(
               radius - (StatusBarComponent.statusBarWidth / 2),
               -StatusBarComponent.statusBarHeight - 4,
             ),
             fillColor: Colors.greenAccent,
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
    healthBar = children.whereType<StatusBarComponent>().first;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox(collisionType: CollisionType.passive));
    updateHealthBar();
  }

  @override
  void update(double dt) {
    if (!isSceneActive) {
      super.update(dt);
      return;
    }

    if (isAttacked) {
      attackedTimer -= dt;

      if (attackedTimer <= 0) {
        isAttacked = false;
        paint.color = encounterModel.type.color;
      }
    }

    final scene = game.gameStateNotifier.getSceneById(sceneModel.id);
    if (scene is EncounterSceneModel && !scene.encounter) {
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
    healthBar.updateStatusBar(health, encounterModel.health);
  }

  void moveOnClick() {
    _clickBoostTime = _clickBoostDuration;
  }

  void resetHealth() {
    health = encounterModel.health;
    isAttacked = false;
    attackedTimer = 0;
    paint.color = encounterModel.type.color;
    updateHealthBar();
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
