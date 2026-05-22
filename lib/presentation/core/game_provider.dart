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
      ResourceType.food: Resource(type: ResourceType.food),
    };

    return GameStateData(resources: resources);
  }

  GameStateData copyWith({Map<ResourceType, Resource>? resources}) {
    return GameStateData(resources: resources ?? this.resources);
  }
}

class GameStateNotifier extends AsyncNotifier<GameStateData> {
  static const double _statePublishInterval = 0.25;

  double _statePublishTimer = 0;
  late GameStateData _currentData;

  GameStateData get currentData => _currentData;

  @override
  FutureOr<GameStateData> build() {
    _currentData = GameStateData.initial();
    return _currentData;
  }

  void _publish() {
    state = AsyncData(
      _currentData.copyWith(resources: _currentData.resources.copyWith()),
    );
    _statePublishTimer = 0;
  }

  Resource get(ResourceType type) {
    return _currentData.resources[type] ??= Resource(type: type);
  }

  void _mutateResource(
    ResourceType type,
    void Function(Resource resource) mutate,
  ) {
    final resource = get(type);
    mutate(resource);
    _publish();
  }

  void add(ResourceType type, double amount) {
    if (amount <= 0) return;

    _mutateResource(type, (resource) {
      resource.add(amount);
    });
  }

  void subtract(ResourceType type, double amount) {
    if (amount <= 0) return;

    _mutateResource(type, (resource) {
      resource.subtract(amount);
    });
  }

  void upgradeResource(ResourceType type, double amount) {
    if (amount <= 0) return;

    _mutateResource(type, (resource) {
      resource.upgrade(amount);
    });
  }

  void buyUpgradeResource(ResourceType type) {
    _mutateResource(type, (resource) {
      resource.buyUpgrade();
    });
  }

  void downgradeResource(ResourceType type, double amount) {
    if (amount <= 0) return;

    _mutateResource(type, (resource) {
      resource.downgrade(amount);
    });
  }

  void resetResource(
    ResourceType type, {
    bool amount = false,
    bool rate = false,
  }) {
    _mutateResource(type, (resource) {
      resource.reset(amount, rate);
    });
  }

  void toggleEncounter(ResourceType type, bool toggle) {
    final resource = get(type);

    if (resource.encounter == toggle) return;

    resource.toggleEncounter(toggle);
    _publish();
  }

  void defeatEncounter(ResourceType type, double baseReward) {
    _mutateResource(type, (resource) {
      final reward = baseReward * resource.enemyRewardMultiplier;
      resource.add(reward);
    });
  }
}

extension _ResourceMapCopy on Map<ResourceType, Resource> {
  Map<ResourceType, Resource> copyWith() {
    return map((type, resource) => MapEntry(type, resource.copyWith()));
  }
}
