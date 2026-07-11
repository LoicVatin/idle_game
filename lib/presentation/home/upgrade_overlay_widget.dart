import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/resource_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/data/models/creature/worker_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/presentation/core/game_provider.dart';
import 'package:idle_game/utils/build_context_helper.dart';
import 'package:idle_game/core/styles/app_colors.dart';

class UpgradeOverlay extends ConsumerWidget {
  const UpgradeOverlay({super.key, required this.game, required this.onClose});

  final IdleGame game;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(gameStateProvider);

    final playground = data.playgrounds.firstWhere(
      (playground) => playground.id == game.upgradeOverlayPlaygroundId,
      orElse: () => data.playgrounds.first,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          onClose();
        }
      },
      child: GestureDetector(
        onTap: onClose,
        child: Material(
          color: AppColors.dark.withValues(alpha: 0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    border: Border.all(color: AppColors.black, width: 2),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                playground.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              onPressed: onClose,
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Flexible(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              _workerCard(context, playground.worker),
                              const SizedBox(height: 8),
                              _sceneUpgradeCard(
                                context,
                                playground.firstScene,
                                data.resources[playground
                                        .firstScene
                                        .generationRateUpgradeCostType] ??
                                    Resource(
                                      type: playground
                                          .firstScene
                                          .generationRateUpgradeCostType,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              _sceneUpgradeCard(
                                context,
                                playground.secondScene,
                                data.resources[playground
                                        .secondScene
                                        .generationRateUpgradeCostType] ??
                                    Resource(
                                      type: playground
                                          .secondScene
                                          .generationRateUpgradeCostType,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              _sceneUpgradeCard(
                                context,
                                playground.thirdScene,
                                data.resources[playground
                                        .thirdScene
                                        .generationRateUpgradeCostType] ??
                                    Resource(
                                      type: playground
                                          .thirdScene
                                          .generationRateUpgradeCostType,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _workerCard(BuildContext context, WorkerModel worker) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent.withValues(alpha: 0.2), AppColors.lightDark],
          begin: Alignment.topLeft,
          end: AlignmentGeometry.bottomCenter,
        ),
        border: Border.all(color: AppColors.black, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 8,
            children: [
              Icon(worker.primaryIcon),
              Expanded(
                child: Text(
                  worker.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.analytics_outlined),
              Text(worker.level.toStringAsPrecision(3)),
            ],
          ),
          //
          Row(
            spacing: 8,
            children: [
              Icon(Icons.linear_scale),
              Expanded(
                child: LinearProgressIndicator(
                  value: (worker.experience / worker.experienceNeededToLevelUp),
                ),
              ),
              Icon(Icons.plus_one_outlined),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Icon(Icons.health_and_safety_outlined),
              Expanded(
                child: Text(
                  context.text.worker_health_indicator(
                    worker.health.toStringAsPrecision(3),
                    worker.maxHealth.toStringAsPrecision(3),
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.energy_savings_leaf_outlined),
              Expanded(
                child: Text(
                  context.text.worker_stamina_indicator(
                    worker.stamina.toStringAsPrecision(3),
                    worker.maxStamina.toStringAsPrecision(3),
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          //
          Row(
            spacing: 8,
            children: [
              Icon(Icons.handyman_outlined),
              Expanded(
                child: Text(
                  worker.secondaryIcon.codePoint.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.gavel_outlined),
              Expanded(
                child: Text(
                  context.text.worker_damage_indicator(
                    worker.damage.toStringAsPrecision(3),
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sceneUpgradeCard(
    BuildContext context,
    SceneModel scene,
    Resource resource,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scene.backgroundColor.withValues(alpha: 0.2),
            AppColors.lightDark,
          ],
          begin: Alignment.topLeft,
          end: AlignmentGeometry.bottomCenter,
        ),
        border: Border.all(color: AppColors.black, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      child: switch (scene) {
        EncounterSceneModel() => _encounterSceneUpgradeCard(
          context,
          scene,
          resource,
        ),
        RestSceneModel() => _restSceneUpgradeCard(context, scene, resource),
        SceneModel() => Container(),
      },
    );
  }

  Widget _encounterSceneUpgradeCard(
    BuildContext context,
    EncounterSceneModel scene,
    Resource resource,
  ) {
    final upgradeCost = scene.generationRateUpgradeCost;
    final canUpgrade = scene.canLevelUpGenerationRate(resource.amount);
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(scene.icon),
            Expanded(
              child: Text(
                scene.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(Icons.run_circle_outlined),
            Text(
              context.text.per_second_indicator(
                scene.generationRatePerSecond.toStringAsPrecision(3),
              ),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Icon(Icons.directions_run),
            Expanded(
              child: Text(
                '+${context.text.per_second_indicator(scene.generationRateUpgradeAmount.toStringAsPrecision(3))}',
              ),
            ),
            _upgradeProgressionBar(
              scene.generationRateLevel,
              scene.generationRateMaxLevel,
            ),
          ],
        ),

        Row(
          spacing: 8,
          children: [
            Icon(scene.generationRateUpgradeCostType.icon),
            Expanded(child: Text(upgradeCost.toStringAsPrecision(3))),
            FilledButton.icon(
              onPressed: canUpgrade
                  ? () {
                      game.gameStateNotifier.buySceneUpgrade(scene.id);
                    }
                  : null,
              icon: const Icon(Icons.trending_up),
              label: Text(
                scene.isMaxLevelGenerationRate
                    ? context.text.upgrade_maxed_button
                    : context.text.upgrade_button,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _restSceneUpgradeCard(
    BuildContext context,
    RestSceneModel scene,
    Resource resource,
  ) {
    final upgradeCost = scene.generationRateUpgradeCost;
    final canUpgrade = scene.canLevelUpGenerationRate(resource.amount);
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(scene.icon),
            Expanded(
              child: Text(
                scene.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(Icons.healing),
            Text(
              context.text.per_second_indicator(
                scene.generationRatePerSecond.toStringAsPrecision(3),
              ),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Icon(Icons.monitor_heart),
            Expanded(
              child: Text(
                '+${context.text.per_second_indicator(scene.generationRateUpgradeAmount.toStringAsPrecision(3))}',
              ),
            ),
            _upgradeHalfProgressionBar(
              scene.generationRateLevel,
              scene.generationRateMaxLevel,
            ),
          ],
        ),

        Row(
          spacing: 8,
          children: [
            Icon(scene.generationRateUpgradeCostType.icon),
            Expanded(child: Text(upgradeCost.toStringAsPrecision(3))),
            FilledButton.icon(
              onPressed: canUpgrade
                  ? () {
                      game.gameStateNotifier.buySceneUpgrade(scene.id);
                    }
                  : null,
              icon: const Icon(Icons.trending_up),
              label: Text(
                scene.isMaxLevelGenerationRate
                    ? context.text.upgrade_maxed_button
                    : context.text.upgrade_button,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _upgradeProgressionBar(int current, int max) {
    return Row(
      children: [
        for (int i = 1; i <= max; i++)
          Icon(i <= current ? Icons.square : Icons.square_outlined),
      ],
    );
  }

  Widget _upgradeHalfProgressionBar(int current, int max) {
    return Row(
      children: [
        for (int i = 1; i <= max; i++)
          if (i % 2 == 0 && i <= current)
            Icon(Icons.battery_full_outlined)
          else if (i == current && i % 2 != 0)
            Icon(Icons.battery_3_bar_outlined)
          else if (i % 2 != 0 && i > current)
            Icon(Icons.battery_0_bar_outlined),
      ],
    );
  }
}
