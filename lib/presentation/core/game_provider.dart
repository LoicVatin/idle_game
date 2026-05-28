import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/worker_model.dart';
import 'package:idle_game/data/models/encounter_model.dart';
import 'package:idle_game/data/models/resource_model.dart';
import 'package:idle_game/data/models/resting_spot_model.dart';

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
      PlaygroundModel(
        id: 0,
        name: "Playground",
        worker: WorkerModel(
          icon: Icons.hiking_outlined,
          toolsIcon: Icons.gavel_sharp,
        ),
        scenes: {
          // Forest
          SceneModel(
            id: 0,
            name: "Forest",
            icon: Icons.forest,
            backgroundColor: Colors.green,
            upgradeCostType: ResourceType.wood,
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
          SceneModel(
            id: 1,
            name: "Cave",
            icon: Icons.warehouse,
            backgroundColor: Colors.grey,
            upgradeCostType: ResourceType.stone,
            encounters: WeightedRandom({
              EncounterModel(
                type: ResourceType.wood,
                health: 25,
                reward: 10,
                icon: Icons.inventory,
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
          /*SceneModel(
            id: 2,
            name: "Plain",
            icon: Icons.wb_twilight,
            backgroundColor: Colors.lightGreen,
            upgradeCostType: ResourceType.food,
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
          ),*/
          // Resting Spot
          RestingSpotModel(
            id: 2,
            name: "Camp",
            icon: Icons.fireplace_outlined,
            backgroundColor: Colors.lightBlue,
            upgradeCostType: ResourceType.food,
            healthRegenPerSecond: 5,
            staminaRegenPerSecond: 10,
          ),
        },
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

  SceneModel getSceneById(int id) {
    for (final playground in _currentData.playgrounds) {
      final scene = playground.getSceneById(id);
      if (scene != null) return scene;
    }
    throw StateError('Scene with id $id not found in any Playground');
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

  void _mutateScene(int id, void Function(SceneModel scene) mutate) {
    final scene = getSceneById(id);
    mutate(scene);
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

  void buySceneUpgrade(int id) {
    final scene = getPlaygroundById(id).activeScene;
    final resource = getResourceByType(scene.upgradeCostType);

    resource.amount -= scene.getUpgradeCost();
    scene.buyUpgrade();
    _publish();
  }

  void upgradeScene(int id, double amount) {
    if (amount <= 0) return;

    _mutateScene(getPlaygroundById(id).activeSceneId, (scene) {
      scene.upgrade(amount);
    });
  }

  void downgradeScene(int id, double amount) {
    if (amount <= 0) return;

    _mutateScene(getPlaygroundById(id).activeSceneId, (scene) {
      scene.downgrade(amount);
    });
  }

  void resetScene(int id) {
    _mutateScene(getPlaygroundById(id).activeSceneId, (scene) {
      scene.reset();
    });
  }

  void resetResource(ResourceType type) {
    _mutateResource(type, (resource) {
      resource.reset();
    });
  }

  void toggleEncounter(int id, bool toggle) {
    final scene = getSceneById(id);

    if (scene.encounter == toggle) return;

    scene.toggleEncounter(toggle);
    _publish();
  }

  void defeatEncounter(int id, ResourceType type, double baseReward) {
    final scene = getSceneById(id);

    _mutateResource(type, (resource) {
      final reward = baseReward * scene.enemyRewardMultiplier;
      resource.add(reward);
    });
  }

  void switchActiveScene(int playgroundId, int sceneId) {
    if (getPlaygroundById(playgroundId).activeSceneId == sceneId) return;

    _mutatePlayground(playgroundId, (playground) {
      playground.setActiveScene(sceneId);
    });
  }
}

extension _ResourceMapCopy on Map<ResourceType, Resource> {
  Map<ResourceType, Resource> copyWith() {
    return map((type, resource) => MapEntry(type, resource.copyWith()));
  }
}
