import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/core/game/components/encounter_component.dart';
import 'package:idle_game/data/models/resource_model.dart';

class WorkerComponent extends RectangleComponent
    with HasGameReference<IdleGame>, CollisionCallbacks {
  final ResourceType type;
  bool isAttacking = false;
  double attackTimer = 0;

  static const double _attackDuration = 0.15;
  static const double _confrontationAttackInterval = 0.35;

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
    attackTimer = _attackDuration;
    paint.color = const Color(0xFFFFF176);
  }

  void updateConfrontation(double dt) {
    final target = confrontationTarget;

    if (target == null || target.isRemoved) {
      endConfrontation();
      return;
    }

    final resource = game.gameStateNotifier.get(type);
    if (!resource.encounter) {
      return;
    }

    confrontationAttackTimer -= dt;

    if (confrontationAttackTimer > 0) {
      return;
    }

    confrontationAttackTimer = _confrontationAttackInterval;
    attack();

    final defeated = target.takeDamage(resource.damage);

    if (defeated) {
      target.removeFromParent();
      game.gameStateNotifier.defeatEncounter(type, target.reward);
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

      game.gameStateNotifier.toggleEncounter(type, true);
    });
  }

  void endConfrontation() {
    confrontationTarget = null;
    confrontationAttackTimer = 0;
    game.gameStateNotifier.toggleEncounter(type, false);
  }
}
