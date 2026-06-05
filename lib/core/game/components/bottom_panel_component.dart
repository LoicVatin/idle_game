import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/rectangle_button_component.dart';
import 'package:idle_game/core/game/components/resource_cost_component.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/resource_model.dart';

class BottomPanelComponent extends PositionComponent
    with HasGameReference<IdleGame> {
  BottomPanelComponent({
    super.position,
    super.size,
    super.anchor,
    super.priority = 10,
    this.padding = const EdgeInsets.all(16),
    required this.onPressed,
  });

  final EdgeInsets padding;
  late final RectangleComponent _resourceAmountsBackground;
  late final RowComponent _resourceAmountsRow;
  late final RectangleButtonComponent _button;

  final Map<ResourceType, ResourceCostComponent> _resourceTexts = {};

  final VoidCallback? onPressed;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    final gameStateNotifier = game.gameStateNotifier;
    _resourceTexts
      ..clear()
      ..addEntries(
        gameStateNotifier.currentData.resources.entries.map((entry) {
          return MapEntry(
            entry.key,
            ResourceCostComponent(
              resource: entry.value,
              upgradeCost: gameStateNotifier.playgroundCost.toDouble(),
            ),
          );
        }),
      );

    _resourceAmountsBackground = RectangleComponent(
      size: Vector2.copy(size),
      paint: Paint()..color = Colors.black,
    );

    add(_resourceAmountsBackground);

    _button = RectangleButtonComponent(icon: Icons.add, onPressed: onPressed);

    _resourceAmountsRow = RowComponent(
      position: Vector2(padding.left, padding.top),
      size: Vector2(size.x - padding.horizontal, size.y - padding.vertical),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      gap: 16,
      children: [
        TextComponent(text: "Cost"),
        ColumnComponent(gap: 2, children: _resourceTexts.values.toList()),
        _button,
      ],
    );
    add(_resourceAmountsRow);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final gameStateNotifier = game.gameStateNotifier;

    for (final entry in gameStateNotifier.currentData.resources.entries) {
      _resourceTexts[entry.key]?.resource = entry.value;
      _resourceTexts[entry.key]?.upgradeCost = gameStateNotifier.playgroundCost
          .toDouble();
    }

    _button.isDisabled = !gameStateNotifier.canBuyPlayground;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _resourceAmountsBackground.size.setFrom(this.size);
      _resourceAmountsRow
        ..position.setValues(padding.left, padding.top)
        ..size.setValues(
          this.size.x - padding.horizontal,
          this.size.y - padding.vertical,
        );
    }
  }
}
