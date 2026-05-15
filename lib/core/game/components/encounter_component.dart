import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/IdleGame.dart';
import 'package:idle_game/data/models/resource_model.dart';

class EncounterComponent extends RectangleComponent
    with HasGameReference<IdleGame>, CollisionCallbacks {
  ResourceType type;

  EncounterComponent({
    required this.type,
    double radius = 24,
    super.position,
    super.anchor,
  }) : super(
         size: Vector2.all(radius * 2),
         paint: Paint()..color = Colors.red,
         children: [
           IconComponent(
             icon: switch (type) {
               ResourceType.food => Icons.grass_outlined,
               ResourceType.wood => Icons.forest_outlined,
               ResourceType.stone => Icons.landscape_outlined,
             },
             size: Vector2.all(radius),
             anchor: Anchor.bottomLeft,
             position: Vector2.all(radius),
           ),
           IconComponent(
             icon: switch (type) {
               ResourceType.food => Icons.pest_control_rodent_outlined,
               ResourceType.wood => Icons.park_outlined,
               ResourceType.stone => Icons.diamond_outlined,
             },
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
    super.update(dt);

    final resource = game.gameStateNotifier.get(type);
    x -= resource.generationRatePerSecond * dt * 10;
    if (x < -width) {
      removeFromParent();
    }
  }
}
