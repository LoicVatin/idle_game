import 'dart:math';

import 'package:collection/collection.dart';

class WeightedList<T> {
  WeightedList(Map<T, double> allWeights)
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
