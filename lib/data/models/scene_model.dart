import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/data/models/resource_model.dart';

abstract class SceneModel {
  int id;
  String name;
  IconData icon;
  Color backgroundColor;
  double generationRatePerSecond;
  double upgradeAmount;
  double upgradeCost;
  ResourceType upgradeCostType;
  double upgradeMultiplier;

  SceneModel({
    required this.id,
    this.name = "Scene",
    this.icon = Icons.map_outlined,
    this.backgroundColor = Colors.grey,
    this.generationRatePerSecond = 0.0,
    this.upgradeAmount = 0,
    this.upgradeCost = 25,
    this.upgradeCostType = ResourceType.wood,
    this.upgradeMultiplier = 0.5,
  });

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
