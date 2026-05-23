import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/data/models/encounter_model.dart';
import 'package:idle_game/data/models/resource_model.dart';
import 'package:idle_game/data/models/worker_model.dart';

class PlaygroundModel {
  int id;
  String name;
  Color backgroundColor;
  double encounterInterval;
  double encounterSpacing;
  double generationRatePerSecond;
  bool encounter;
  double enemyRewardMultiplier;
  double upgradeAmount;
  double upgradeCost;
  ResourceType upgradeCostType;
  double upgradeMultiplier;
  WorkerModel worker;
  WeightedRandom<EncounterModel> encounters;

  PlaygroundModel({
    required this.id,
    this.name = "Playground",
    this.backgroundColor = Colors.grey,
    this.encounterInterval = 25,
    this.encounterSpacing = 100,
    this.generationRatePerSecond = 0.0,
    this.encounter = false,
    this.enemyRewardMultiplier = 1,
    this.upgradeAmount = 0,
    this.upgradeCost = 25,
    this.upgradeCostType = ResourceType.wood,
    this.upgradeMultiplier = 0.5,
    WorkerModel? worker,
    WeightedRandom<EncounterModel>? encounters,
  }) : worker =
           worker ??
           WorkerModel(
             damage: 1,
             icon: Icons.man_outlined,
             toolsIcon: Icons.waving_hand_outlined,
           ),
       encounters =
           encounters ??
           WeightedRandom({
             EncounterModel(
               type: ResourceType.wood,
               health: 3,
               reward: 5,
               icon: Icons.data_object_outlined,
             ): 1,
           });

  PlaygroundModel copyWith({
    int? id,
    String? name,
    Color? backgroundColor,
    double? encounterInterval,
    double? encounterSpacing,
    double? generationRatePerSecond,
    bool? encounter,
    double? enemyRewardMultiplier,
  }) {
    return PlaygroundModel(
      id: id ?? this.id,
      name: name ?? this.name,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      encounterInterval: encounterInterval ?? this.encounterInterval,
      encounterSpacing: encounterSpacing ?? this.encounterSpacing,
      generationRatePerSecond:
          generationRatePerSecond ?? this.generationRatePerSecond,
      encounter: encounter ?? this.encounter,
      enemyRewardMultiplier:
          enemyRewardMultiplier ?? this.enemyRewardMultiplier,
    );
  }

  void upgrade(double value) => generationRatePerSecond += value;

  void buyUpgrade() {
    generationRatePerSecond += (upgradeMultiplier * (upgradeAmount + 1));
    upgradeAmount++;
  }

  double getUpgradeCost() {
    return upgradeCost * (upgradeAmount + 1);
  }

  bool canBuyUpgrade(double amount) {
    return amount >= getUpgradeCost();
  }

  void downgrade(double value) {
    generationRatePerSecond = (generationRatePerSecond - value).clamp(
      0.0,
      double.infinity,
    );
  }

  void reset() {
    generationRatePerSecond = 0.0;
    upgradeAmount = 0.0;
  }

  void toggleEncounter(bool encounter) => this.encounter = encounter;
}

//
class WeightedRandom<T> {
  WeightedRandom(Map<T, double> allWeights)
    : _totalWeight = allWeights.values.sum,
      _allWeightsList = allWeights.entries.toList(growable: true);

  double _totalWeight;
  final Random _random = Random.secure();
  final List<MapEntry<T, double>> _allWeightsList;

  void add(T entry, double weight) {
    _allWeightsList.add(MapEntry(entry, weight));
    _totalWeight += weight;
  }

  T getNext() {
    final weightedRandom = _random.nextDouble() * _totalWeight;
    double totalSoFar = 0;
    for (final entry in _allWeightsList) {
      if (weightedRandom < totalSoFar + entry.value) {
        return entry.key;
      }
      totalSoFar += entry.value;
    }
    return _allWeightsList.last.key;
  }
}
