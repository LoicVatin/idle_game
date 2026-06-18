import 'package:flutter/material.dart';
import 'package:idle_game/data/models/creature/creature_model.dart';
import 'package:idle_game/data/models/creature/creature_state.dart';
import 'package:idle_game/data/models/resource_model.dart';

class EncounterModel extends CreatureModel {
  final ResourceType type;
  final double reward;
  final bool canWalk;

  EncounterModel({
    required super.name,
    required super.primaryIcon,
    required super.secondaryIcon,
    super.spriteSheet,
    super.level = 1,
    super.maxLevel,
    super.experience,
    super.maxHealth,
    super.stamina,
    super.healthIncreasePerLevel,
    super.maxStamina,
    super.health,
    super.staminaIncreasePerLevel,
    super.damage = 0,
    super.damageIncreasePerLevel,
    super.staminaCostPerAttack,
    super.state,
    required this.type,
    required this.reward,
    this.canWalk = false,
  });

  void updateState({
    required bool isWorkerDepleted,
    required bool isInConfrontationStep,
    bool isMoving = false,
  }) {
    if (isInConfrontationStep) {
      state = isWorkerDepleted ? CreatureState.depleted : CreatureState.attack;
      return;
    }
    if (isWorkerDepleted) {
      state = CreatureState.depleted;
      return;
    }
    if (isMoving) {
      state = canWalk ? CreatureState.walk : CreatureState.idle;
      return;
    }
  }

  @override
  EncounterModel copyWith({
    String? name,
    IconData? primaryIcon,
    IconData? secondaryIcon,
    String? spriteSheet,
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
    ResourceType? type,
    double? reward,
    bool? canWalk,
    CreatureState? state,
  }) {
    return EncounterModel(
      name: name ?? super.name,
      primaryIcon: primaryIcon ?? super.primaryIcon,
      secondaryIcon: secondaryIcon ?? super.secondaryIcon,
      spriteSheet: spriteSheet ?? super.spriteSheet,
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
      type: type ?? this.type,
      reward: reward ?? this.reward,
      canWalk: canWalk ?? this.canWalk,
      state: state ?? this.state,
    );
  }
}
