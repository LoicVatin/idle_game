import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
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
  late ParallaxComponent parallaxComponent;
  late TextComponent _nameComponent;
  late TextComponent rateComponent;

  final String defaultSpriteSheetFolder = "backgrounds/";
  final String defaultSpriteSheet = "background";

  bool _isReloadingParallax = false;

  List<ParallaxImageData> get _parallaxImages => [
    ParallaxImageData(
      '${defaultSpriteSheetFolder}backgrounds_${scene.spriteSheet ?? defaultSpriteSheet}_5.png',
    ),
    ParallaxImageData(
      '${defaultSpriteSheetFolder}backgrounds_${scene.spriteSheet ?? defaultSpriteSheet}_4.png',
    ),
    ParallaxImageData(
      '${defaultSpriteSheetFolder}backgrounds_${scene.spriteSheet ?? defaultSpriteSheet}_3.png',
    ),
    ParallaxImageData(
      '${defaultSpriteSheetFolder}backgrounds_${scene.spriteSheet ?? defaultSpriteSheet}_2.png',
    ),
    ParallaxImageData(
      '${defaultSpriteSheetFolder}backgrounds_${scene.spriteSheet ?? defaultSpriteSheet}_1.png',
    ),
    ParallaxImageData(
      '${defaultSpriteSheetFolder}backgrounds_${scene.spriteSheet ?? defaultSpriteSheet}_0.png',
    ),
  ];

  Future<ParallaxComponent> _loadParallaxComponent() {
    return game.loadParallaxComponent(
      _parallaxImages,
      size: size.clone(),
      baseVelocity: Vector2(0.0, 0.0),
      velocityMultiplierDelta: Vector2(1.5, 1.0),
    );
  }

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
      priority: 10,
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

    parallaxComponent = await _loadParallaxComponent();
    add(parallaxComponent);

    _updateResponsivePositions(force: true);
  }

  Vector2? _lastSize;

  @override
  void update(double dt) {
    isVisible = scene.active;

    final rateText = _formatRate(scene.generationRatePerSecond);
    if (_lastRateText != rateText) {
      _lastRateText = rateText;
      rateComponent.text = rateText;
    }

    _updateResponsivePositions();

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

  Future<void> _reloadParallaxAfterResize() async {
    if (_isReloadingParallax || isRemoved) {
      return;
    }

    _isReloadingParallax = true;

    final oldParallaxComponent = parallaxComponent;
    final oldPriority = oldParallaxComponent.priority;

    final newParallaxComponent = await _loadParallaxComponent();

    if (isRemoved) {
      newParallaxComponent.removeFromParent();
      _isReloadingParallax = false;
      return;
    }

    newParallaxComponent.priority = oldPriority;
    parallaxComponent = newParallaxComponent;

    oldParallaxComponent.removeFromParent();
    add(parallaxComponent);

    _isReloadingParallax = false;
  }

  void _updateResponsivePositions({bool force = false}) {
    if (!force && _lastSize?.x == width && _lastSize?.y == height) {
      return;
    }

    _lastSize = size.clone();


    _borderComponent.size.setFrom(size.clone());
    parallaxComponent.size.setFrom(size.clone());
    unawaited(_reloadParallaxAfterResize());

    rateComponent.position.setValues(width - padding, height - padding);
  }
}
