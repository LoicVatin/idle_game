import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/worker_model.dart';
import 'package:idle_game/data/models/encounter_model.dart';
import 'package:idle_game/data/models/resource_model.dart';

final gameStateProvider =
    AsyncNotifierProvider<GameStateNotifier, GameStateData>(
      GameStateNotifier.new,
    );

@immutable
class GameStateData {
  final Map<ResourceType, Resource> resources;
  final Set<PlaygroundModel> playgrounds;

  const GameStateData({required this.resources, required this.playgrounds});

  factory GameStateData.initial() {
    final resources = {
      ResourceType.wood: Resource(type: ResourceType.wood),
      ResourceType.stone: Resource(type: ResourceType.stone),
      ResourceType.food: Resource(type: ResourceType.food),
    };

    final playgrounds = {
      // Forest
      PlaygroundModel(
        id: 0,
        name: "Forest",
        backgroundColor: Colors.green,
        upgradeCostType: ResourceType.wood,
        worker: WorkerModel(
          icon: Icons.hiking_outlined,
          toolsIcon: Icons.carpenter_sharp,
        ),
        encounters: WeightedRandom({
          EncounterModel(
            type: ResourceType.wood,
            health: 3,
            reward: 5,
            icon: Icons.park,
          ): 1,
          EncounterModel(
            type: ResourceType.wood,
            health: 12,
            reward: 15,
            icon: Icons.forest,
          ): 0.1,
          EncounterModel(
            type: ResourceType.stone,
            health: 5,
            reward: 3,
            icon: Icons.scatter_plot,
          ): 0.2,
        }),
      ),

      // Cave
      PlaygroundModel(
        id: 1,
        name: "Cave",
        backgroundColor: Colors.grey,
        upgradeCostType: ResourceType.stone,
        worker: WorkerModel(
          icon: Icons.nordic_walking_outlined,
          toolsIcon: Icons.gavel_sharp,
        ),
        encounters: WeightedRandom({
          EncounterModel(
            type: ResourceType.wood,
            health: 25,
            reward: 10,
            icon: Icons.warehouse,
          ): 0.1,
          EncounterModel(
            type: ResourceType.stone,
            health: 4,
            reward: 5,
            icon: Icons.landslide,
          ): 1,
          EncounterModel(
            type: ResourceType.food,
            health: 3,
            reward: 2,
            icon: Icons.pest_control_rodent,
          ): 0.2,
        }),
      ),

      // Plain
      PlaygroundModel(
        id: 2,
        name: "Plain",
        backgroundColor: Colors.lightGreen,
        upgradeCostType: ResourceType.food,
        worker: WorkerModel(
          icon: Icons.directions_walk_outlined,
          toolsIcon: Icons.restaurant_menu_sharp,
        ),
        encounters: WeightedRandom({
          EncounterModel(
            type: ResourceType.food,
            health: 3,
            reward: 5,
            icon: Icons.foggy,
          ): 1,
          EncounterModel(
            type: ResourceType.wood,
            health: 25,
            reward: 10,
            icon: Icons.cabin,
          ): 0.2,
          EncounterModel(
            type: ResourceType.stone,
            health: 3,
            reward: 2,
            icon: Icons.landslide,
          ): 0.5,
        }),
      ),
    };

    return GameStateData(resources: resources, playgrounds: playgrounds);
  }

  GameStateData copyWith({
    Map<ResourceType, Resource>? resources,
    Set<PlaygroundModel>? playgrounds,
  }) {
    return GameStateData(
      resources: resources ?? this.resources,
      playgrounds: playgrounds ?? this.playgrounds,
    );
  }
}

class GameStateNotifier extends AsyncNotifier<GameStateData> {
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
  }

  Resource getResourceByType(ResourceType type) {
    return _currentData.resources[type] ??= Resource(type: type);
  }

  PlaygroundModel getPlaygroundById(int id) {
    return _currentData.playgrounds.firstWhere(
      (playground) => playground.id == id,
    );
  }

  void _mutateResource(
    ResourceType type,
    void Function(Resource resource) mutate,
  ) {
    final resource = getResourceByType(type);
    mutate(resource);
    _publish();
  }

  void _mutatePlayground(
    int id,
    void Function(PlaygroundModel playground) mutate,
  ) {
    final playground = getPlaygroundById(id);
    mutate(playground);
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

  void buyPlaygroundUpgrade(int id) {
    final playground = getPlaygroundById(id);
    final resource = getResourceByType(playground.upgradeCostType);

    resource.amount -= playground.getUpgradeCost();
    playground.buyUpgrade();
    _publish();
  }

  void upgradePlayground(int type, double amount) {
    if (amount <= 0) return;

    _mutatePlayground(type, (playground) {
      playground.upgrade(amount);
    });
  }

  void downgradePlayground(int type, double amount) {
    if (amount <= 0) return;

    _mutatePlayground(type, (playground) {
      playground.downgrade(amount);
    });
  }

  void resetPlayground(int id) {
    _mutatePlayground(id, (playground) {
      playground.reset();
    });
  }

  void resetResource(ResourceType type) {
    _mutateResource(type, (resource) {
      resource.reset();
    });
  }

  void toggleEncounter(int id, bool toggle) {
    final playground = getPlaygroundById(id);

    if (playground.encounter == toggle) return;

    playground.toggleEncounter(toggle);
    _publish();
  }

  void defeatEncounter(int id, ResourceType type, double baseReward) {
    final playground = getPlaygroundById(id);

    _mutateResource(type, (resource) {
      final reward = baseReward * playground.enemyRewardMultiplier;
      resource.add(reward);
    });
  }
}

extension _ResourceMapCopy on Map<ResourceType, Resource> {
  Map<ResourceType, Resource> copyWith() {
    return map((type, resource) => MapEntry(type, resource.copyWith()));
  }
}
