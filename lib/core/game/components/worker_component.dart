import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/IdleGame.dart';
import 'package:idle_game/data/models/resource_model.dart';

import 'encounter_component.dart';

class WorkerComponent extends RectangleComponent
    with HasGameReference<IdleGame>, CollisionCallbacks {
  ResourceType type;
  bool isAttacking = false;
  double attackTimer = 0;

  final double confrontationAttackInterval = 0.35;
  EncounterComponent? confrontationTarget;
  double confrontationAttackTimer = 0;

  WorkerComponent({
    required this.type,
    double radius = 24,
    super.position,
    super.anchor,
  }) : super(
         size: Vector2.all(radius * 2),
         paint: Paint()..color = Colors.green,
         children: [
           IconComponent(
             icon: Icons.hiking_sharp,
             size: Vector2.all(radius),
             anchor: Anchor.bottomRight,
             position: Vector2.all(radius),
           ),
           IconComponent(
             icon: switch (type) {
               ResourceType.food => Icons.restaurant_menu_sharp,
               ResourceType.wood => Icons.carpenter_sharp,
               ResourceType.stone => Icons.gavel_sharp,
             },
             size: Vector2.all(radius),
             anchor: Anchor.topLeft,
             position: Vector2.all(radius),
           ),
         ],
       );

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isAttacking) {
      attackTimer -= dt;

      if (attackTimer <= 0) {
        isAttacking = false;
        paint.color = Colors.green;
      }
    }

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
    isAttacking = true;
    attackTimer = 0.15;
    paint.color = const Color(0xFFFFF176);
  }

  void updateConfrontation(double dt) {
    final resource = game.gameStateNotifier.currentData.resources[type]!;
    final target = confrontationTarget;

    if (!resource.encounter) return;

    if (target == null || target.isRemoved) {
      endConfrontation();
      return;
    }

    confrontationAttackTimer -= dt;

    if (confrontationAttackTimer > 0) {
      return;
    }

    confrontationAttackTimer = confrontationAttackInterval;
    attack();

    final defeated = target.takeDamage(resource.damage);

    if (defeated) {
      target.removeFromParent();
      game.gameStateNotifier.defeatEncounter(type, target.reward);
      endConfrontation();
    }
  }

  void startConfrontation(EncounterComponent enemy) {
    print("startConfrontation");
    final resource = game.gameStateNotifier.currentData.resources[type]!;
    if (confrontationTarget == enemy) {
      return;
    }

    confrontationTarget = enemy;
    confrontationAttackTimer = 0;
    game.gameStateNotifier.toggleEncounter(type, true);
  }

  void endConfrontation() {
    final resource = game.gameStateNotifier.currentData.resources[type]!;
    confrontationTarget = null;
    confrontationAttackTimer = 0;
    game.gameStateNotifier.toggleEncounter(type, false);
  }
}
