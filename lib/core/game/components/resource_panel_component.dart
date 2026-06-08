import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/resource_component.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/resource_model.dart';

class ResourcePanelComponent extends PositionComponent
    with HasGameReference<IdleGame> {
  ResourcePanelComponent({
    super.position,
    super.size,
    super.anchor,
    super.priority = 10,
    this.padding = const EdgeInsets.all(16),
  });

  final EdgeInsets padding;
  late final RectangleComponent _resourceAmountsBackground;
  late final RowComponent _resourceAmountsRow;
  final Map<ResourceType, ResourceComponent> _resourceTexts = {};
  StreamSubscription? _subscription;

  @override
  void onMount() {
    super.onMount();
    _subscription = game.gameStateNotifier.onUpdate.listen(
      (_) => _updateState(),
    );
    _updateState();
  }

  @override
  void onRemove() {
    _subscription?.cancel();
    super.onRemove();
  }

  void _updateState() {
    final gameStateNotifier = game.gameStateNotifier;
    for (final entry in gameStateNotifier.currentData.resources.entries) {
      _resourceTexts[entry.key]?.resource = entry.value;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    final gameStateNotifier = game.gameStateNotifier;
    _resourceTexts
      ..clear()
      ..addEntries(
        gameStateNotifier.currentData.resources.entries.map((entry) {
          return MapEntry(entry.key, ResourceComponent(resource: entry.value));
        }),
      );

    _resourceAmountsBackground = RectangleComponent(
      size: Vector2.copy(size),
      paint: Paint()..color = Colors.black,
    );

    add(_resourceAmountsBackground);

    _resourceAmountsRow = RowComponent(
      position: Vector2(padding.left, padding.top),
      size: Vector2(size.x - padding.horizontal, size.y - padding.vertical),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _resourceTexts.values.toList(),
    );
    add(_resourceAmountsRow);
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
