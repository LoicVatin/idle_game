import 'package:idle_game/core/game/components/scene/scene_component.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';

class RestSceneComponent extends SceneComponent<RestSceneModel> {
  RestSceneComponent({
    required super.playground,
    required super.scene,
    super.size,
    super.position,
    super.visible,
    super.priority,
  });

  @override
  String get defaultSpriteSheet => "background";

  @override
  void onSceneActive(double dt) {
    playground.worker.restoreHealth(
      scene.generationRatePerSecond * scene.healthRegenPerSecond * dt,
    );
    playground.worker.restoreStamina(
      scene.generationRatePerSecond * scene.staminaRegenPerSecond * dt,
    );
  }

  @override
  void onSceneInactive(double dt) {}

  @override
  void onSceneTap() {
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
}
