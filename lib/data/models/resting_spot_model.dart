import 'package:flutter/material.dart';
import 'package:idle_game/data/models/resource_model.dart';
import 'package:idle_game/data/models/scene_model.dart';

class RestingSpotModel extends SceneModel {
  final double healthRegenPerSecond;
  final double staminaRegenPerSecond;

  RestingSpotModel({
    required super.id,
    super.name = 'Resting Spot',
    super.icon = Icons.fireplace_outlined,
    super.backgroundColor = Colors.lightBlue,
    super.upgradeCostType = ResourceType.food,
    this.healthRegenPerSecond = 5,
    this.staminaRegenPerSecond = 10,
  }) : super(
         generationRatePerSecond: 0.1,
         encounterInterval: double.infinity,
         encounterSpacing: double.infinity,
       );
}
