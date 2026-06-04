import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/encounter_scene_model.dart';
import 'package:idle_game/data/models/resource_model.dart';
import 'package:idle_game/data/models/rest_scene_model.dart';
import 'package:idle_game/data/models/worker_model.dart';
import 'package:idle_game/presentation/core/game_provider.dart';

class UpgradeOverlay extends ConsumerWidget {
  const UpgradeOverlay({super.key, required this.game, required this.onClose});

  final IdleGame game;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    return gameState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Unable to load upgrade data: $error'),
            ),
          ),
        );
      },
      data: (data) {
        final playground = data.playgrounds.firstWhere(
          (playground) => playground.id == game.upgradeOverlayPlaygroundId,
          orElse: () => data.playgrounds.first,
        );

        return GestureDetector(
          onTap: onClose,
          child: Material(
            color: Colors.black54,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
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
                                ...playground.scenes.map((scene) {
                                  final resource =
                                      data.resources[scene
                                          .generationRateUpgradeCostType] ??
                                      Resource(
                                        type:
                                            scene.generationRateUpgradeCostType,
                                      );

                                  if (scene is EncounterSceneModel) {
                                    return _encounterSceneUpgradeCard(
                                      context,
                                      scene,
                                      resource,
                                    );
                                  } else if (scene is RestSceneModel) {
                                    return _restSceneUpgradeCard(
                                      context,
                                      scene,
                                      resource,
                                    );
                                  }
                                  return Container();
                                }),
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
        );
      },
    );
  }

  Widget _workerCard(BuildContext context, WorkerModel worker) {
    return Card(
      color: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(worker.icon),
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
                    value: (worker.experience / worker.experienceNeeded),
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
                    "${worker.health.toStringAsPrecision(3)} / ${worker.maxHealth.toStringAsPrecision(3)}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Icon(Icons.energy_savings_leaf_outlined),
                Expanded(
                  child: Text(
                    "${worker.stamina.toStringAsPrecision(3)} / ${worker.maxStamina.toStringAsPrecision(3)}",
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
                    "${worker.toolsIcon.codePoint}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Icon(Icons.gavel_outlined),
                Expanded(
                  child: Text(
                    "${worker.damage.toStringAsPrecision(3)} dmg",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _encounterSceneUpgradeCard(
    BuildContext context,
    EncounterSceneModel scene,
    Resource resource,
  ) {
    final upgradeCost = scene.generationRateUpgradeCost;
    final canUpgrade = scene.canLevelUpGenerationRate(resource.amount);
    return Card(
      color: scene.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
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
                  '${scene.generationRatePerSecond.toStringAsExponential(2)}/s',
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                Icon(Icons.directions_run),
                Expanded(
                  child: Text(
                    '+${scene.generationRateUpgradeAmount.toStringAsExponential(2)}/s',
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
                Expanded(child: Text(upgradeCost.toStringAsExponential(2))),
                FilledButton.icon(
                  onPressed: canUpgrade
                      ? () {
                          game.gameStateNotifier.buySceneUpgrade(scene.id);
                        }
                      : null,
                  icon: const Icon(Icons.trending_up),
                  label: Text(
                    scene.isMaxLevelGenerationRate ? 'Maxed out' : 'Upgrade',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _restSceneUpgradeCard(
    BuildContext context,
    RestSceneModel scene,
    Resource resource,
  ) {
    final upgradeCost = scene.generationRateUpgradeCost;
    final canUpgrade = scene.canLevelUpGenerationRate(resource.amount);
    return Card(
      color: scene.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
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
                  '${scene.generationRatePerSecond.toStringAsExponential(2)}/s',
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                Icon(Icons.monitor_heart),
                Expanded(
                  child: Text(
                    '+${scene.generationRateUpgradeAmount.toStringAsExponential(2)}/s',
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
                Expanded(child: Text(upgradeCost.toStringAsExponential(2))),
                FilledButton.icon(
                  onPressed: canUpgrade
                      ? () {
                          game.gameStateNotifier.buySceneUpgrade(scene.id);
                        }
                      : null,
                  icon: const Icon(Icons.trending_up),
                  label: Text(
                    scene.isMaxLevelGenerationRate ? 'Maxed out' : 'Upgrade',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
