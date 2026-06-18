import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/creature/creature_component.dart';
import 'package:idle_game/data/models/creature/creature_state.dart';
import 'package:idle_game/core/game/components/creature/encounter_component.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/data/models/creature/worker_model.dart';

class WorkerComponent extends CreatureComponent<WorkerModel> {
  final PlaygroundModel playgroundModel;

  @override
  String get defaultSpriteSheetFolder => "workers/";

  @override
  String get defaultSpriteSheet => "worker";

  double _lastConfrontationAttackTimer = 0;

  WorkerComponent({
    required this.playgroundModel,
    required super.model,
    super.position,
    super.anchor,
    super.color = Colors.blueAccent,
    super.statusOrder = StatusOrder.statusHealthStamina,
    super.primaryIconAnchor = Anchor.bottomRight,
    super.secondaryIconAnchor = Anchor.topLeft,
    super.priority = 50,
  }) : super();

  @override
  void update(double dt) {
    super.update(dt);
    updateCreatureState(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is EncounterComponent) {
      game.gameStateNotifier.startConfrontation(
        playgroundModel.id,
        other.model,
      );
    }
  }

  // Creature overrides
  @override
  void updateCreatureState(double dt) {
    super.updateCreatureState(dt);

    if (isInConfrontation) {
      timer -= dt;

      if (timer <= 0) {
        isInConfrontation = false;
        paint.color = Colors.blueAccent.withValues(alpha: 0.3);
      }
    }

    final scene = playgroundModel.activeScene;
    final encounterAttackHappened =
        scene is EncounterSceneModel &&
        scene.encounter &&
        playgroundModel.confrontationAttackTimer >
            _lastConfrontationAttackTimer;

    if (encounterAttackHappened) {
      onConfrontation();
    }

    model.updateState(
      scene: scene,
      encounterAttackHappened: encounterAttackHappened,
    );

    state = model.state;
    _lastConfrontationAttackTimer = playgroundModel.confrontationAttackTimer;
  }

  @override
  SceneModel get scene => playgroundModel.activeScene;

  @override
  bool isStatusAlwaysVisible() {
    return false;
  }

  @override
  bool isHealthBarAlwaysVisible() {
    final scene = playgroundModel.activeScene;
    return scene is RestSceneModel;
  }

  @override
  bool isStaminaBarAlwaysVisible() {
    final scene = playgroundModel.activeScene;
    return scene is RestSceneModel;
  }

  @override
  void defeat() {
    state = CreatureState.idle;
    game.gameStateNotifier.toggleEncounter(
      playgroundModel.activeScene.id,
      false,
    );
  }
}
