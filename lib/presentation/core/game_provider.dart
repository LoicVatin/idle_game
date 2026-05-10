import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/resource_model.dart';

final gameStateProvider =
    AsyncNotifierProvider<GameStateNotifier, GameStateData>(
      GameStateNotifier.new,
    );

@immutable
class GameStateData {
  final Map<ResourceType, Resource> resources;

  const GameStateData({required this.resources});

  factory GameStateData.initial() {
    final resources = {
      ResourceType.wood: Resource(type: ResourceType.wood),
      ResourceType.stone: Resource(type: ResourceType.stone),
      ResourceType.food: Resource(type: ResourceType.food)
    };

    return GameStateData(resources: resources);
  }

  GameStateData copyWith({Map<ResourceType, Resource>? resources}) {
    return GameStateData(resources: resources ?? this.resources);
  }
}

class GameStateNotifier extends AsyncNotifier<GameStateData> {
  GameStateData get currentData => state.value ?? GameStateData.initial();

  @override
  FutureOr<GameStateData> build() {
    return GameStateData.initial();
  }

  void _setData(GameStateData data) {
    state = AsyncData(data);
  }

  Resource get(ResourceType type) {
    print("get");
    return currentData.resources.putIfAbsent(type, () => Resource(type: type));
  }

  void add(ResourceType type, double amount) {
    print("add ($amount)");
    if (amount <= 0) return;

    final data = currentData;
    final resources = currentData.resources.copyWith();
    final resource = resources.putIfAbsent(type, () => Resource(type: type));

    resource.add(amount);
    _setData(data.copyWith(resources: resources));
  }

  void subtract(ResourceType type, double amount) {
    print("subtract ($amount)");
    if (amount <= 0) return;

    final data = currentData;
    final resources = currentData.resources.copyWith();
    final resource = resources.putIfAbsent(type, () => Resource(type: type));

    resource.subtract(amount);
    _setData(data.copyWith(resources: resources));
  }

  void upgradeResource(ResourceType type, double amount) {
    print("upgradeResource ($amount)");
    if (amount <= 0) return;

    final data = currentData;
    final resources = currentData.resources.copyWith();
    final resource = resources.putIfAbsent(type, () => Resource(type: type));

    resource.upgrade(amount);
    _setData(data.copyWith(resources: resources));
  }

  void downgradeResource(ResourceType type, double amount) {
    print("downgradeResource ($amount)");
    if (amount <= 0) return;

    final data = currentData;
    final resources = currentData.resources.copyWith();
    final resource = resources.putIfAbsent(type, () => Resource(type: type));

    resource.downgrade(amount);
    _setData(data.copyWith(resources: resources));
  }

  void resetResource(ResourceType type, {bool amount =false, bool rate = false}) {
    print("resetResource()");

    final data = currentData;
    final resources = currentData.resources.copyWith();
    final resource = resources.putIfAbsent(type, () => Resource(type: type));

    resource.reset(amount, rate);
    _setData(data.copyWith(resources: resources));
  }

  void updateResource(double dt) {
    if (dt <= 0) return;

    final data = currentData;
    final resources = currentData.resources.copyWith();
    for(final resource in resources.values) {
      final generatedAmount = resource.generationRatePerSecond * dt;

      resource.add(generatedAmount.toDouble());
    }

    _setData(data.copyWith(resources: resources));
  }
}

extension _ResourceMapCopy on Map<ResourceType, Resource> {
  Map<ResourceType, Resource> copyWith() {
    return map(
          (type, resource) => MapEntry(
        type,
        resource.copyWith(),
      ),
    );
  }
}
