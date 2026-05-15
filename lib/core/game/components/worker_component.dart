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
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is EncounterComponent) {
      print("onCollisionStart");
    }
  }
}
