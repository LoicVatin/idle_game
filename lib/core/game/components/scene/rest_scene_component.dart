import 'package:idle_game/core/game/components/scene/scene_component.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';

class RestSceneComponent extends SceneComponent<RestSceneModel> {
  RestSceneComponent({
    required super.playground,
    required super.scene,
    required super.onDefeated,
    super.size,
    super.position,
    super.visible,
    super.priority,
  });

  @override
  void update(double dt) {
    super.update(dt);

    if (scene.active) {
      playground.worker.restoreHealth(
        scene.generationRatePerSecond * scene.healthRegenPerSecond * dt,
      );
      playground.worker.restoreStamina(
        scene.generationRatePerSecond * scene.staminaRegenPerSecond * dt,
      );
      encounterTimer = 0;
    }
  }

  @override
  void moveOnClick() {
    RestSceneModel restingSpotModel = scene;
    playground.worker.restoreHealth(
      restingSpotModel.generationRatePerSecond *
          restingSpotModel.healthRegenPerSecond,
    );
    playground.worker.restoreStamina(
      restingSpotModel.generationRatePerSecond *
          restingSpotModel.staminaRegenPerSecond,
    );
  }

  @override
  void handleWorkerDefeated() {
    //resetEncounters();
    onDefeated;
  }
}
