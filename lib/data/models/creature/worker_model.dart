import 'package:flutter/cupertino.dart';
import 'package:idle_game/data/models/creature/creature_model.dart';

class WorkerModel extends CreatureModel {
  WorkerModel({
    required super.name,
    required super.primaryIcon,
    required super.secondaryIcon,
    super.level = 1,
    super.maxLevel,
    super.experience,
    super.maxHealth,
    super.stamina,
    super.healthIncreasePerLevel,
    super.maxStamina,
    super.health,
    super.staminaIncreasePerLevel,
    super.damage,
    super.damageIncreasePerLevel,
    super.staminaCostPerAttack,
  });

  @override
  CreatureModel copyWith({
    String? name,
    IconData? primaryIcon,
    IconData? secondaryIcon,
    int? level,
    int? maxLevel,
    double? experience,
    double? x,
    double? y,
    double? maxHealth,
    double? health,
    double? healthIncreasePerLevel,
    double? maxStamina,
    double? stamina,
    double? staminaIncreasePerLevel,
    double? damage,
    double? damageIncreasePerLevel,
    double? staminaCostPerAttack,
  }) {
    return WorkerModel(
      name: name ?? super.name,
      primaryIcon: primaryIcon ?? super.primaryIcon,
      secondaryIcon: secondaryIcon ?? super.secondaryIcon,
      level: level ?? super.level,
      maxLevel: maxLevel ?? super.maxLevel,
      experience: experience ?? super.experience,
      maxHealth: maxHealth ?? super.maxHealth,
      health: health ?? super.health,
      healthIncreasePerLevel:
          healthIncreasePerLevel ?? super.healthIncreasePerLevel,
      maxStamina: maxStamina ?? super.maxStamina,
      stamina: stamina ?? super.stamina,
      staminaIncreasePerLevel:
          staminaIncreasePerLevel ?? super.staminaIncreasePerLevel,
      damage: damage ?? super.damage,
      damageIncreasePerLevel:
          damageIncreasePerLevel ?? super.damageIncreasePerLevel,
      staminaCostPerAttack: staminaCostPerAttack ?? super.staminaCostPerAttack,
    );
  }
}
