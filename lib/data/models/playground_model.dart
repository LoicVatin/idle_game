import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/worker_model.dart';

class PlaygroundModel {
  final int id;
  final String name;
  final Set<SceneModel> scenes;
  WorkerModel worker;
  int activeSceneId;

  PlaygroundModel({
    required this.id,
    this.name = "Playground",
    this.activeSceneId = 0,
    WorkerModel? worker,
    Set<SceneModel>? scenes,
  }) : worker =
           worker ??
           WorkerModel(
             damage: 1,
             icon: Icons.man_outlined,
             toolsIcon: Icons.waving_hand_outlined,
           ),
       scenes =
           scenes ??
           {
             EncounterSceneModel(id: 0, playgroundId: id),
             EncounterSceneModel(id: 1, playgroundId: id),
             RestSceneModel(id: 2, playgroundId: id),
           };

  PlaygroundModel copyWith({
    int? id,
    String? name,
    Set<SceneModel>? scenes,
    WorkerModel? worker,
    int? activeSceneId,
  }) {
    return PlaygroundModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scenes: scenes ?? this.scenes,
      worker: worker ?? this.worker,
      activeSceneId: activeSceneId ?? this.activeSceneId,
    );
  }

  SceneModel get activeScene => scenes.firstWhere(
    (scene) => scene.id == activeSceneId,
    orElse: () => scenes.first,
  );

  SceneModel? getSceneById(int id) {
    return scenes.firstWhereOrNull((scene) => scene.id == id);
  }

  void setActiveScene(int id) {
    if (getSceneById(id) != null) activeSceneId = id;
  }

  void addExperience(double baseReward) {
    worker.addExperience(baseReward);
  }
}
