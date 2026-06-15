import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/playground_component.dart';

import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/playground_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/utils/build_context_helper.dart';

abstract class SceneComponent<T extends SceneModel> extends RectangleComponent
    with
        HasGameReference<IdleGame>,
        TapCallbacks,
        HasVisibility,
        ParentIsA<PlaygroundComponent> {
  static const double padding = 10.0;
  static const double _height = 200.0;
  final T scene;
  final PlaygroundModel playground;

  double encounterTimer = 0;
  final VoidCallback? onDefeated;

  String? _lastRateText;

  late RectangleComponent _borderComponent;
  late TextComponent _nameComponent;
  late TextComponent rateComponent;

  SceneComponent({
    required this.playground,
    required this.scene,
    required this.onDefeated,
    super.size,
    super.position,
    bool visible = false,
    super.priority,
  }) {
    isVisible = visible;
  }

  @override
  FutureOr<void> onLoad() async {
    size = Vector2.all(_height);

    paint = Paint()..color = scene.backgroundColor;

    _nameComponent = TextComponent(
      text: scene.name,
      position: Vector2.all(padding),
      textRenderer: TextPaint(style: game.textTheme.titleLarge),
    );
    add(_nameComponent);

    rateComponent = TextComponent(
      anchor: Anchor.bottomRight,
      text: _lastRateText,
      position: Vector2(width - padding, height - padding),
      priority: 10,
      textRenderer: TextPaint(style: game.textTheme.titleLarge),
    );
    add(rateComponent);

    _borderComponent = RectangleComponent(
      size: size.clone(),
      paint: Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      priority: 100,
    );
    add(_borderComponent);
  }

  @override
  void update(double dt) {
    isVisible = scene.active;

    _borderComponent.size.setFrom(size.clone());

    final rateText = _formatRate(scene.generationRatePerSecond);
    if (_lastRateText != rateText) {
      _lastRateText = rateText;
      rateComponent.text = rateText;
    }

    rateComponent.position.setValues(width - padding, height - padding);

    super.update(dt);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return isVisible && super.containsLocalPoint(point);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isVisible) {
      return;
    }
    super.onTapDown(event);
    moveOnClick();
  }

  void moveOnClick();

  void handleWorkerDefeated();

  String _formatRate(double rate) =>
      '(${game.text.per_second_indicator(rate.toStringAsPrecision(3))})';
}
