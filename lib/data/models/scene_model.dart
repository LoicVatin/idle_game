import 'dart:math';
import 'package:flutter/material.dart';
import 'package:idle_game/data/models/resource_model.dart';

abstract class SceneModel {
  int id;
  int playgroundId;
  String name;
  IconData icon;
  Color backgroundColor;
  final String? spriteSheet;
  final double x = 0.1;
  final double y = 2.0;
  int generationRateLevel;
  final int generationRateMaxLevel;
  double generationRateUpgradeAmount;
  double generationRatePerSecond;
  ResourceType generationRateUpgradeCostType;
  bool active;

  SceneModel({
    required this.id,
    required this.playgroundId,
    this.name = "Scene",
    this.spriteSheet,
    this.icon = Icons.map_outlined,
    this.backgroundColor = Colors.grey,
    this.generationRateLevel = 0,
    this.generationRatePerSecond = 0.0,
    this.generationRateMaxLevel = 5,
    this.generationRateUpgradeAmount = 1.0,
    this.generationRateUpgradeCostType = ResourceType.wood,
    this.active = false,
  });

  num get generationRateUpgradeCost =>
      pow((generationRateLevel.toDouble() + 1 / x), y);

  bool get isMaxLevelGenerationRate =>
      generationRateLevel == generationRateMaxLevel;

  bool canLevelUpGenerationRate(double amount) {
    return amount >= generationRateUpgradeCost &&
        generationRateLevel < generationRateMaxLevel;
  }

  void levelUpGenerationRate() {
    generationRateLevel++;
    generationRatePerSecond += generationRateUpgradeAmount;
  }

  void levelDownGenerationRate() {
    generationRateLevel--;
    generationRatePerSecond -= generationRateUpgradeAmount;
  }

  void downgrade(double value) {
    generationRatePerSecond = (generationRatePerSecond - value).clamp(
      0.0,
      double.infinity,
    );
  }

  void reset() {
    generationRatePerSecond = 0.0;
    generationRateLevel = 0;
  }
}
