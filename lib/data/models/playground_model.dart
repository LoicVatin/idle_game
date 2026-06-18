import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/creature/worker_model.dart';
import 'package:idle_game/data/models/creature/encounter_model.dart';

class PlaygroundModel {
  final int id;
  final String name;
  final EncounterSceneModel firstScene;
  final EncounterSceneModel secondScene;
  final RestSceneModel thirdScene;
  late final Set<SceneModel> _scenes;
  WorkerModel worker;
  EncounterModel? confrontationTarget;
  double confrontationAttackTimer = 0;

  PlaygroundModel({
    required this.id,
    this.name = "Playground",
    WorkerModel? worker,
    EncounterSceneModel? firstScene,
    EncounterSceneModel? secondScene,
    RestSceneModel? thirdScene,
    this.confrontationTarget,
    this.confrontationAttackTimer = 0,
  }) : worker =
           worker ??
           WorkerModel(
             name: "Worker",
             damage: 1,
             primaryIcon: Icons.man_outlined,
             secondaryIcon: Icons.waving_hand_outlined,
           ),
       firstScene =
           firstScene ??
           EncounterSceneModel(id: 0, playgroundId: id, active: true),
       secondScene =
           secondScene ?? EncounterSceneModel(id: 1, playgroundId: id),
       thirdScene = thirdScene ?? RestSceneModel(id: 2, playgroundId: id) {
    _scenes = {this.firstScene, this.secondScene, this.thirdScene};
  }

  PlaygroundModel copyWith({
    int? id,
    String? name,
    EncounterSceneModel? firstScene,
    EncounterSceneModel? secondScene,
    RestSceneModel? thirdScene,
    WorkerModel? worker,
    int? activeSceneId,
    EncounterModel? confrontationTarget,
    double? confrontationAttackTimer,
  }) {
    return PlaygroundModel(
      id: id ?? this.id,
      name: name ?? this.name,
      firstScene: firstScene ?? this.firstScene,
      secondScene: secondScene ?? this.secondScene,
      thirdScene: thirdScene ?? this.thirdScene,
      worker: worker ?? this.worker,
      confrontationTarget: confrontationTarget ?? this.confrontationTarget,
      confrontationAttackTimer:
          confrontationAttackTimer ?? this.confrontationAttackTimer,
      //activeSceneId: activeSceneId ?? this.activeSceneId,
    );
  }

  SceneModel get activeScene =>
      _scenes.firstWhere((scene) => scene.active, orElse: () => _scenes.first);

  SceneModel? getSceneById(int id) {
    return _scenes.firstWhereOrNull((scene) => scene.id == id);
  }

  void setActiveScene(int id) {
    for (final scene in _scenes) {
      scene.active = scene.id == id;
    }
    //if (getSceneById(id) != null) activeSceneId = id;
  }

  void addExperience(double baseReward) {
    worker.addExperience(baseReward);
  }
}
