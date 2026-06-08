import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/worker_model.dart';
import 'package:idle_game/data/models/adventure_model.dart';
import 'package:idle_game/data/models/encounter_model.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/resource_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/utils/logger_helper.dart';

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
    appLogger.d("GameStateData.initial()");
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
          name: "Explorer",
          icon: Icons.hiking_outlined,
          toolsIcon: Icons.gavel_sharp,
        ),
        activeSceneId: 0,
        scenes: {
          // Forest
          EncounterSceneModel(
            id: 0,
            playgroundId: 0,
            name: "Forest",
            icon: Icons.forest_outlined,
            backgroundColor: Colors.green,
            generationRateUpgradeCostType: ResourceType.wood,
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
              EncounterModel(
                type: ResourceType.food,
                health: 3,
                damage: 1,
                reward: 5,
                icon: Icons.pest_control_rodent,
              ): 0.2,
            }),
          ),

          // Cave
          EncounterSceneModel(
            id: 1,
            playgroundId: 0,
            name: "Deep Forest",
            icon: Icons.forest,
            backgroundColor: Colors.green.shade900,
            generationRateUpgradeCostType: ResourceType.stone,
            encounters: WeightedRandom({
              EncounterModel(
                type: ResourceType.wood,
                health: 3,
                reward: 5,
                icon: Icons.park,
              ): 1,
              EncounterModel(
                type: ResourceType.stone,
                health: 4,
                reward: 5,
                icon: Icons.landslide,
              ): 0.5,
              EncounterModel(
                type: ResourceType.food,
                health: 5,
                damage: 3,
                reward: 4,
                icon: Icons.savings,
              ): 0.5,
              EncounterModel(
                type: ResourceType.wood,
                health: 25,
                reward: 10,
                icon: Icons.inventory,
              ): 0.1,
            }),
          ),
          // Resting Spot
          RestSceneModel(
            id: 2,
            playgroundId: 0,
            name: "Camp fire",
            icon: Icons.fireplace_outlined,
            backgroundColor: Colors.green.shade600,
            generationRateUpgradeCostType: ResourceType.food,
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

  final _updateController = StreamController<void>.broadcast();

  Stream<void> get onUpdate => _updateController.stream;

  @override
  FutureOr<GameStateData> build() {
    _currentData = GameStateData.initial();
    return _currentData;
  }

  void _publish() {
    _currentData = _currentData.copyWith(
      resources: Map.from(_currentData.resources),
      playgrounds: Set.from(_currentData.playgrounds),
    );
    state = AsyncData(_currentData);
    _updateController.add(null);
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
    final scene = getSceneById(id);
    final resource = getResourceByType(scene.generationRateUpgradeCostType);

    resource.amount -= scene.generationRateUpgradeCost;
    scene.levelUpGenerationRate();
    _publish();
  }

  void buyActiveSceneUpgrade(int id) {
    final scene = getPlaygroundById(id).activeScene;
    buySceneUpgrade(scene.id);
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

    if (scene is EncounterSceneModel) {
      if (scene.encounter == toggle) return;

      scene.toggleEncounter(toggle);
      _publish();
    }
  }

  void defeatEncounter(int id, ResourceType type, double baseReward) {
    final scene = getSceneById(id);

    if (scene is EncounterSceneModel) {
      _mutateResource(type, (resource) {
        final reward = baseReward * scene.enemyRewardMultiplier;
        resource.add(reward);
      });

      _mutatePlayground(scene.playgroundId, (playground) {
        playground.addExperience(baseReward);
      });
    }
  }

  void switchActiveScene(int playgroundId, int sceneId) {
    if (getPlaygroundById(playgroundId).activeSceneId == sceneId) return;

    _mutatePlayground(playgroundId, (playground) {
      playground.setActiveScene(sceneId);
    });
  }

  final double x = 0.1;
  final double y = 2.0;

  num get playgroundCost => pow((_currentData.playgrounds.length) / x, y);

  bool get canBuyPlayground {
    for (final resource in _currentData.resources.values) {
      if (resource.amount < playgroundCost.toDouble()) {
        return false;
      }
    }

    return true;
  }

  PlaygroundModel addPlayground() {
    final increment = _currentData.playgrounds.last.id + 10;

    final adventure = Adventure.randomAdventure();

    final playground = PlaygroundModel(
      id: increment + 0,
      name: "${adventure.name} $increment",
      worker: WorkerModel(
        name: "${adventure.workerName} $increment",
        icon: adventure.workerIcon,
        toolsIcon: adventure.workerTool,
      ),
      scenes: {
        // Forest
        EncounterSceneModel(
          id: increment + 0,
          playgroundId: increment + 0,
          name: adventure.encounterOneName,
          icon: adventure.encounterOneIcon,
          backgroundColor: adventure.encounterOneColor,
          generationRateUpgradeCostType: ResourceType.wood,
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
            EncounterModel(
              type: ResourceType.food,
              health: 3,
              damage: 1,
              reward: 5,
              icon: Icons.pest_control_rodent,
            ): 0.2,
          }),
        ),

        // Cave
        EncounterSceneModel(
          id: increment + 1,
          playgroundId: increment + 0,
          name: adventure.encounterTwoName,
          icon: adventure.encounterTwoIcon,
          backgroundColor: adventure.encounterTwoColor,
          generationRateUpgradeCostType: ResourceType.stone,
          encounters: WeightedRandom({
            EncounterModel(
              type: ResourceType.wood,
              health: 3,
              reward: 5,
              icon: Icons.park,
            ): 1,
            EncounterModel(
              type: ResourceType.stone,
              health: 4,
              reward: 5,
              icon: Icons.landslide,
            ): 0.5,
            EncounterModel(
              type: ResourceType.food,
              health: 5,
              damage: 3,
              reward: 4,
              icon: Icons.savings,
            ): 0.5,
            EncounterModel(
              type: ResourceType.wood,
              health: 25,
              reward: 10,
              icon: Icons.inventory,
            ): 0.1,
          }),
        ),
        // Resting Spot
        RestSceneModel(
          id: increment + 2,
          playgroundId: increment + 0,
          name: adventure.restName,
          icon: adventure.restIcon,
          backgroundColor: adventure.restColor,
          generationRateUpgradeCostType: ResourceType.food,
          healthRegenPerSecond: 5,
          staminaRegenPerSecond: 10,
        ),
      },
    );
    playground.activeSceneId = playground.scenes.first.id;

    for (final resource in _currentData.resources.values) {
      resource.subtract(playgroundCost.toDouble());
    }

    _currentData.playgrounds.add(playground);
    _publish();

    return playground;
  }
}
