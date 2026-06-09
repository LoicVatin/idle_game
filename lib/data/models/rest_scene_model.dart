import 'package:flutter/material.dart';
import 'package:idle_game/data/models/resource_model.dart';
import 'package:idle_game/data/models/scene_model.dart';

class RestSceneModel extends SceneModel {
  final double healthRegenPerSecond;
  final double staminaRegenPerSecond;

  RestSceneModel({
    required super.id,
    required super.playgroundId,
    super.name = 'Resting Spot',
    super.icon = Icons.fireplace_outlined,
    super.backgroundColor = Colors.lightBlue,
    super.generationRateUpgradeCostType = ResourceType.food,
    this.healthRegenPerSecond = 5,
    this.staminaRegenPerSecond = 10,
  }) : super(
         generationRatePerSecond: 0.1,
         generationRateUpgradeAmount: 0.1,
         generationRateLevel: 1,
         generationRateMaxLevel: 10,
       );
}
