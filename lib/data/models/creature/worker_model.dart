import 'package:flutter/cupertino.dart';
import 'package:idle_game/data/models/creature/creature_model.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/creature/creature_state.dart';

class WorkerModel extends CreatureModel {
  WorkerModel({
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
    super.damage,
    super.damageIncreasePerLevel,
    super.staminaCostPerAttack,
    super.state,
  });

  void updateState({
    required SceneModel scene,
    required bool encounterAttackHappened,
  }) {
    if (scene is RestSceneModel) {
      state = CreatureState.rest;
      return;
    }

    if (scene is EncounterSceneModel && !scene.encounter) {
      state = (scene.generationRatePerSecond > 0 || clickBoostTime > 0)
          ? CreatureState.walk
          : CreatureState.idle;
      return;
    }

    if (scene is EncounterSceneModel && scene.encounter) {
      if (encounterAttackHappened) {
        clickBoostTime = 0.0;
      }

      if (!isAlive) {
        state = CreatureState.defeat;
      } else if (!canAttack) {
        state = CreatureState.depleted;
      } else {
        state = CreatureState.attack;
      }
    }
  }

  @override
  CreatureModel copyWith({
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
    CreatureState? state,
  }) {
    return WorkerModel(
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
      state: state ?? this.state,
    );
  }
}
