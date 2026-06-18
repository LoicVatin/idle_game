import 'package:flame/components.dart';
import 'package:idle_game/core/game/components/scene/scene_component.dart';

import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/core/game/components/creature/creature_component.dart';
import 'package:idle_game/core/game/components/creature/encounter_component.dart';

class EncounterSceneComponent extends SceneComponent<EncounterSceneModel> {
  EncounterSceneComponent({
    required super.playground,
    required super.scene,
    required super.onDefeated,
    super.size,
    super.position,
    super.visible,
    super.priority,
  });

  @override
  String get defaultSpriteSheet => "background";

  double clickBoostTime = 0;
  static const double clickBoostDuration = 0.6;
  static const double clickBoostVelocity = 3;

  @override
  void update(double dt) {
    super.update(dt);

    if (scene.active) {
      //if (scene.generationRatePerSecond > 0 && !scene.encounter) {
      //  encounterTimer += dt * scene.generationRatePerSecond * 10;
      //}

      //if (encounterTimer >= scene.encounterInterval) {
      //  encounterTimer = 0;
      if (!scene.encounter && clickBoostTime > 0) {
        clickBoostTime -= dt;
      }
      if(scene.encounter) {
        clickBoostTime = 0;
      }

      final parallax = parallaxComponent.parallax;
      parallax?.baseVelocity = Vector2(scene.encounter ? 0.0 : (scene.generationRatePerSecond + (clickBoostTime > 0 ? clickBoostVelocity : 0.0)), 0.0);
      generateEncounter();
      //}
    } else {
      resetEncounterHealth(scene.id);
    }
  }

  void generateEncounter() {
    final creatureComponentRadius = CreatureComponent.componentRadius;
    final defaultSpawnX = width;
    var maxEncounterX = double.negativeInfinity;

    for (final child in children) {
      if (child is! EncounterComponent) {
        continue;
      }

      if (child.x - creatureComponentRadius > width) {
        return;
      }

      if (child.x > maxEncounterX) {
        maxEncounterX = child.x;
      }
    }

    final hasEncounters = maxEncounterX.isFinite;
    final spawnX = hasEncounters
        ? maxEncounterX + creatureComponentRadius + scene.encounterSpacing
        : defaultSpawnX;

    if (spawnX > defaultSpawnX) {
      return;
    }

    add(
      EncounterComponent(
        scene: scene,
        model: scene.encounters.getNext().copyWith(),
        position: Vector2(spawnX, height - SceneComponent.padding),
        anchor: Anchor.bottomLeft,
      ),
    );
  }

  void resetEncounters() {
    for (final encounter in children.whereType<EncounterComponent>().toList()) {
      encounter.removeFromParent();
    }
  }

  void resetEncounterHealth(int sceneId) {
    for (final encounter in children.whereType<EncounterComponent>()) {
      encounter.resetHealth();
    }
  }

  @override
  void moveOnClick() {
    encounterTimer += scene.encounterInterval / 10;
    clickBoostTime = clickBoostDuration;

    for (final encounter in children.whereType<EncounterComponent>()) {
      encounter.moveOnClick();
    }

    parent.workerComponent.moveOnClick();
  }

  @override
  void handleWorkerDefeated() {
    resetEncounters();
    onDefeated;
  }
}
