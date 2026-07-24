import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/creature/worker_model.dart';
import 'package:idle_game/data/models/adventure_model.dart';
import 'package:idle_game/data/models/creature/creature_model.dart';
import 'package:idle_game/data/models/creature/encounter_model.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/resource_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/utils/logger_helper.dart';
import 'package:idle_game/utils/weighted_list.dart';

final gameStateProvider = NotifierProvider<GameStateNotifier, GameStateData>(
  GameStateNotifier.new,
);

@immutable
class GameStateData {
  final Map<ResourceType, Resource> resources;
  final Set<PlaygroundModel> playgrounds;

  const GameStateData({required this.resources, required this.playgrounds});

  static WeightedList<EncounterModel> _firstSceneEncounters() => WeightedList({
    EncounterModel(
      name: "Tree",
      type: ResourceType.wood,
      maxHealth: 3,
      reward: 5,
      primaryIcon: Icons.park,
      secondaryIcon: ResourceType.wood.icon,
      spriteSheet: "tree",
    ): 1,
    EncounterModel(
      name: "Trees",
      type: ResourceType.wood,
      maxHealth: 12,
      reward: 15,
      primaryIcon: Icons.forest,
      secondaryIcon: ResourceType.wood.icon,
      spriteSheet: "tree",
    ): 0.1,
    EncounterModel(
      name: "Pebbles",
      type: ResourceType.stone,
      maxHealth: 5,
      reward: 3,
      primaryIcon: Icons.scatter_plot,
      secondaryIcon: ResourceType.stone.icon,
      spriteSheet: "rock",
    ): 0.2,
    EncounterModel(
      name: "Wolf",
      type: ResourceType.food,
      maxHealth: 3,
      damage: 1,
      reward: 5,
      primaryIcon: Icons.pest_control_rodent,
      secondaryIcon: ResourceType.food.icon,
      spriteSheet: "wolf",
    ): 2,
    EncounterModel(
      name: "Goblin",
      type: ResourceType.food,
      maxHealth: 3,
      damage: 1,
      reward: 5,
      primaryIcon: Icons.pest_control_rodent,
      secondaryIcon: ResourceType.food.icon,
      spriteSheet: "goblin",
    ): 0.5,
  });

  static WeightedList<EncounterModel> _secondSceneEncounters() => WeightedList({
    EncounterModel(
      name: "Dead Tree",
      type: ResourceType.wood,
      maxHealth: 2,
      reward: 2,
      primaryIcon: Icons.park,
      secondaryIcon: ResourceType.wood.icon,
      spriteSheet: "tree",
    ): 1,
    EncounterModel(
      name: "Rock",
      type: ResourceType.stone,
      maxHealth: 4,
      reward: 5,
      primaryIcon: Icons.landslide,
      secondaryIcon: ResourceType.stone.icon,
      spriteSheet: "rock",
    ): 0.5,
    EncounterModel(
      name: "Goblin",
      type: ResourceType.food,
      maxHealth: 3,
      damage: 1,
      reward: 5,
      primaryIcon: Icons.pest_control_rodent,
      secondaryIcon: ResourceType.food.icon,
      spriteSheet: "goblin",
    ): 2,
    EncounterModel(
      name: "Hobgoblin",
      type: ResourceType.food,
      maxHealth: 5,
      damage: 10,
      reward: 4,
      primaryIcon: Icons.savings,
      secondaryIcon: ResourceType.food.icon,
      spriteSheet: "hobgoblin",
    ): 2,
    EncounterModel(
      name: "Stockpile",
      type: ResourceType.wood,
      maxHealth: 25,
      reward: 10,
      primaryIcon: Icons.inventory,
      secondaryIcon: ResourceType.wood.icon,
    ): 0.1,
  });

  factory GameStateData.initial() {
    appLogger.d("GameStateData.initial()");
    final resources = {
      ResourceType.wood: Resource(
        type: ResourceType.wood,
        amount: kDebugMode ? 1e63 : 0.0,
      ),
      ResourceType.stone: Resource(
        type: ResourceType.stone,
        amount: kDebugMode ? 1e63 : 0.0,
      ),
      ResourceType.food: Resource(
        type: ResourceType.food,
        amount: kDebugMode ? 1e63 : 0.0,
      ),
    };

    final playgrounds = {
      PlaygroundModel(
        id: 0,
        name: "Playground",
        worker: WorkerModel(
          name: "Explorer",
          primaryIcon: Icons.hiking_outlined,
          secondaryIcon: Icons.gavel_sharp,
          spriteSheet: "adventurer",
        ),
        firstScene: EncounterSceneModel(
          id: 0,
          playgroundId: 0,
          name: "Edge of the Woods",
          icon: Icons.forest_outlined,
          backgroundColor: Colors.green,
          spriteSheet: "field",
          generationRateUpgradeCostType: ResourceType.wood,
          active: true,
          encounters: _firstSceneEncounters(),
        ),
        secondScene: EncounterSceneModel(
          id: 1,
          playgroundId: 0,
          name: "Deep Forest",
          icon: Icons.forest,
          backgroundColor: Colors.green.shade900,
          spriteSheet: "dark_forest",
          generationRateUpgradeCostType: ResourceType.stone,
          encounters: _secondSceneEncounters(),
        ),
        thirdScene: RestSceneModel(
          id: 2,
          playgroundId: 0,
          name: "Camp fire",
          icon: Icons.fireplace_outlined,
          backgroundColor: Colors.green.shade600,
          spriteSheet: "campfire",
          generationRateUpgradeCostType: ResourceType.food,
          healthRegenPerSecond: 5,
          staminaRegenPerSecond: 10,
        ),
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

class GameStateNotifier extends Notifier<GameStateData> {
  late GameStateData _currentData;

  GameStateData get currentData => _currentData;

  final _updateController = StreamController<void>.broadcast();
  final _workerDefeatedController = StreamController<int>.broadcast();

  static const double _x = 0.1;
  static const double _y = 2.0;

  num? _cachedPlaygroundCost;

  Stream<void> get onUpdate => _updateController.stream;

  Stream<int> get onWorkerDefeated => _workerDefeatedController.stream;

  int _batchDepth = 0;
  bool _needsPublish = false;

  @override
  GameStateData build() {
    _currentData = GameStateData.initial();
    ref.onDispose(() {
      _updateController.close();
      _workerDefeatedController.close();
    });
    return _currentData;
  }

  void _startBatch() => _batchDepth++;

  void _endBatch() {
    if (--_batchDepth == 0 && _needsPublish) {
      _needsPublish = false;
      _publish();
    }
  }

  void _publish() {
    if (_batchDepth > 0) {
      _needsPublish = true;
      return;
    }
    _currentData = _currentData.copyWith(
      resources: Map.from(_currentData.resources),
      playgrounds: Set.from(_currentData.playgrounds),
    );
    state = _currentData;
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

    resource.subtract(scene.generationRateUpgradeCost.toDouble());
    scene.levelUpGenerationRate();
    _publish();
  }

  void buyActiveSceneUpgrade(int id) {
    final scene = getPlaygroundById(id).activeScene;
    buySceneUpgrade(scene.id);
  }

  void downgradeScene(int id, double amount) {
    if (amount <= 0) return;

    _mutateScene(getPlaygroundById(id).activeScene.id, (scene) {
      scene.downgrade(amount);
    });
  }

  void resetScene(int id) {
    _mutateScene(getPlaygroundById(id).activeScene.id, (scene) {
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
      if (!toggle) {
        _mutatePlayground(scene.playgroundId, (playground) {
          playground.confrontationTarget = null;
          playground.confrontationAttackTimer = 0;
        });
        return;
      }
      _publish();
    }
  }

  void startConfrontation(int playgroundId, EncounterModel target) {
    _startBatch();
    _mutatePlayground(playgroundId, (playground) {
      if (playground.confrontationTarget == target) return;
      playground.confrontationTarget = target;
      playground.confrontationAttackTimer = 0;
      toggleEncounter(playground.activeScene.id, true);
    });
    _endBatch();
  }

  void updatePlaygrounds(double dt) {
    _startBatch();
    for (final playground in _currentData.playgrounds) {
      updatePlayground(playground, dt);
    }
    _endBatch();
  }

  void updatePlayground(PlaygroundModel playground, double dt) {
    final scene = playground.activeScene;
    if (scene is! EncounterSceneModel || !scene.encounter) {
      return;
    }

    final target = playground.confrontationTarget;
    if (target == null) {
      toggleEncounter(scene.id, false);
      return;
    }

    playground.confrontationAttackTimer -= dt;

    if (playground.confrontationAttackTimer > 0) {
      return;
    }

    if (!playground.worker.isAlive || !playground.worker.canAttack) {
      return;
    }

    playground.confrontationAttackTimer =
        CreatureModel.confrontationAttackInterval;

    // Perform attack
    playground.worker.spendAttackStamina();

    final targetDefeated = target.health <= playground.worker.damage;
    target.takeDamage(playground.worker.damage);
    playground.worker.takeDamage(target.damage);

    if (!playground.worker.isAlive) {
      playground.confrontationTarget = null;
      playground.confrontationAttackTimer = 0;
      toggleEncounter(scene.id, false);
      playground.worker.resetExperience();
      _workerDefeatedController.add(playground.id);
      _publish();
      return;
    }

    if (targetDefeated) {
      // Target defeated
      defeatEncounter(scene.id, target.type, target.reward);
      playground.confrontationTarget = null;
      playground.confrontationAttackTimer = 0;
      toggleEncounter(scene.id, false);
    }

    _publish();
  }

  void defeatEncounter(int id, ResourceType type, double baseReward) {
    final scene = getSceneById(id);

    if (scene is EncounterSceneModel) {
      _startBatch();
      _mutateResource(
        type,
        (resource) => resource.add(baseReward * scene.enemyRewardMultiplier),
      );
      _mutatePlayground(
        scene.playgroundId,
        (playground) => playground.addExperience(baseReward),
      );
      _endBatch();
    }
  }

  void switchActiveScene(int playgroundId, int sceneId) {
    if (getPlaygroundById(playgroundId).activeScene.id == sceneId) return;

    _mutatePlayground(playgroundId, (playground) {
      playground.setActiveScene(sceneId);
    });
  }

  num get playgroundCost =>
      _cachedPlaygroundCost ??= pow((_currentData.playgrounds.length) / _x, _y);

  bool get canBuyPlayground {
    final cost = playgroundCost.toDouble();
    return _currentData.resources.values.every((r) => r.amount >= cost);
  }

  PlaygroundModel addPlayground() {
    final cost = playgroundCost.toDouble();
    final increment = _currentData.playgrounds.last.id + 10;

    final adventure = Adventure.randomAdventure();

    final playground = PlaygroundModel(
      id: increment,
      name: "${adventure.name} $increment",
      worker: WorkerModel(
        name: "${adventure.workerName} $increment",
        primaryIcon: adventure.workerIcon,
        secondaryIcon: adventure.workerTool,
        spriteSheet: "adventurer",
      ),
      firstScene: EncounterSceneModel(
        id: increment,
        playgroundId: increment,
        name: adventure.encounterOneName,
        icon: adventure.encounterOneIcon,
        backgroundColor: adventure.encounterOneColor,
        generationRateUpgradeCostType: ResourceType.wood,
        active: true,
        encounters: GameStateData._firstSceneEncounters(),
      ),
      secondScene: EncounterSceneModel(
        id: increment + 1,
        playgroundId: increment,
        name: adventure.encounterTwoName,
        icon: adventure.encounterTwoIcon,
        backgroundColor: adventure.encounterTwoColor,
        generationRateUpgradeCostType: ResourceType.stone,
        encounters: GameStateData._secondSceneEncounters(),
      ),
      thirdScene: RestSceneModel(
        id: increment + 2,
        playgroundId: increment,
        name: adventure.restName,
        icon: adventure.restIcon,
        backgroundColor: adventure.restColor,
        generationRateUpgradeCostType: ResourceType.food,
        healthRegenPerSecond: 5,
        staminaRegenPerSecond: 10,
      ),
    );

    for (final resource in _currentData.resources.values) {
      resource.subtract(cost);
    }

    _currentData.playgrounds.add(playground);
    _cachedPlaygroundCost = null;
    _publish();

    return playground;
  }
}
