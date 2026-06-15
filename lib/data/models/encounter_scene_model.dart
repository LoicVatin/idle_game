import 'package:flutter/material.dart';
import 'package:idle_game/data/models/creature/encounter_model.dart';
import 'package:idle_game/data/models/resource_model.dart';
import 'package:idle_game/data/models/scene_model.dart';

class EncounterSceneModel extends SceneModel {
  WeightedRandom<EncounterModel> encounters;
  double encounterInterval;
  double encounterSpacing;
  bool encounter;
  double enemyRewardMultiplier;

  EncounterSceneModel({
    required super.id,
    required super.playgroundId,
    super.name = "Encounter Scene",
    super.icon = Icons.forest_outlined,
    super.backgroundColor = Colors.green,
    super.generationRateUpgradeCostType = ResourceType.wood,
    super.active,
    this.encounterInterval = 25,
    this.encounterSpacing = 100,
    this.encounter = false,
    this.enemyRewardMultiplier = 1,
    WeightedRandom<EncounterModel>? encounters,
  }) : encounters =
           encounters ??
           WeightedRandom({
             EncounterModel(
               name: "Encounter",
               type: ResourceType.wood,
               maxHealth: 3,
               reward: 5,
               primaryIcon: Icons.data_object_outlined,
               secondaryIcon: Icons.data_object_outlined,
             ): 1,
           }),
       super();

  void toggleEncounter(bool encounter) => this.encounter = encounter;
}
