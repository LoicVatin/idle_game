import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/resource_model.dart';
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

        return Material(
          color: Colors.black54,
          child: Center(
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
                              '${playground.name} upgrades',
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
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: playground.scenes.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final scene = playground.scenes.elementAt(index);
                            final resource =
                                data.resources[scene.upgradeCostType] ??
                                Resource(type: scene.upgradeCostType);
                            final upgradeCost = scene.getUpgradeCost();
                            final canUpgrade = scene.canBuyUpgrade(
                              resource.amount,
                            );

                            return Card(
                              color: scene.backgroundColor,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  spacing: 12,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      spacing: 8,
                                      children: [
                                        Icon(scene.icon),
                                        Expanded(
                                          child: Text(
                                            scene.name,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
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
                                        Text(
                                          'Upgrade: +${(scene.upgradeMultiplier * (scene.upgradeAmount + 1)).toStringAsExponential(2)}/s',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 8,
                                      children: [
                                        Icon(scene.upgradeCostType.icon),
                                        Text(
                                          'Cost: (${upgradeCost.toStringAsExponential(2)}) / (${resource.amount.toStringAsExponential(2)})',
                                        ),
                                      ],
                                    ),
                                    FilledButton.icon(
                                      onPressed: canUpgrade
                                          ? () {
                                              game.gameStateNotifier
                                                  .buySceneUpgrade(scene.id);
                                            }
                                          : null,
                                      icon: const Icon(Icons.trending_up),
                                      label: Text('Upgrade'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
