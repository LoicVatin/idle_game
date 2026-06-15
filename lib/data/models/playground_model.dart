import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/creature/worker_model.dart';

class PlaygroundModel {
  final int id;
  final String name;
  final SceneModel firstScene;
  final SceneModel secondScene;
  final SceneModel thirdScene;
  late final Set<SceneModel> _scenes;
  WorkerModel worker;
  int activeSceneId;

  PlaygroundModel({
    required this.id,
    this.name = "Playground",
    this.activeSceneId = 0,
    WorkerModel? worker,
    SceneModel? firstScene,
    SceneModel? secondScene,
    SceneModel? thirdScene,
  }) : worker =
           worker ??
           WorkerModel(
             name: "Worker",
             damage: 1,
             primaryIcon: Icons.man_outlined,
             secondaryIcon: Icons.waving_hand_outlined,
           ),
       firstScene = firstScene ?? EncounterSceneModel(id: 0, playgroundId: id),
       secondScene =
           secondScene ?? EncounterSceneModel(id: 1, playgroundId: id),
       thirdScene = thirdScene ?? RestSceneModel(id: 2, playgroundId: id) {
    activeSceneId = this.firstScene.id;
    _scenes = {this.firstScene, this.secondScene, this.thirdScene};
  }

  PlaygroundModel copyWith({
    int? id,
    String? name,
    SceneModel? firstScene,
    SceneModel? secondScene,
    SceneModel? thirdScene,
    WorkerModel? worker,
    int? activeSceneId,
  }) {
    return PlaygroundModel(
      id: id ?? this.id,
      name: name ?? this.name,
      firstScene: firstScene ?? this.firstScene,
      secondScene: secondScene ?? this.secondScene,
      thirdScene: thirdScene ?? this.thirdScene,
      worker: worker ?? this.worker,
      activeSceneId: activeSceneId ?? this.activeSceneId,
    );
  }

  SceneModel get activeScene => _scenes.firstWhere(
    (scene) => scene.id == activeSceneId,
    orElse: () => _scenes.first,
  );

  SceneModel? getSceneById(int id) {
    return _scenes.firstWhereOrNull((scene) => scene.id == id);
  }

  void setActiveScene(int id) {
    if (getSceneById(id) != null) activeSceneId = id;
  }

  void addExperience(double baseReward) {
    worker.addExperience(baseReward);
  }
}
