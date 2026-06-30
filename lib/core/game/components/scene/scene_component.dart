import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/component_utils.dart';
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
  static final double padding = Dimensions.extraSmall;
  static const double _height = Dimensions.gigantic;
  final T scene;
  final PlaygroundModel playground;

  double clickBoostTime = 0;
  bool wasActive = false;

  String _lastRateText = '';

  Vector2? _lastSize;
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

  SceneComponent({
    required this.playground,
    required this.scene,
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
      priority: Priorities.low,
      textRenderer: TextPaint(style: game.textTheme.titleLarge),
    );
    add(_nameComponent);

    rateComponent = TextComponent(
      anchor: Anchor.bottomRight,
      text: _lastRateText,
      position: Vector2(width - padding, height - padding),
      priority: Priorities.low,
      textRenderer: TextPaint(style: game.textTheme.titleLarge),
    );
    add(rateComponent);

    _borderComponent = RectangleComponent(
      size: size.clone(),
      paint: Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      priority: Priorities.overlay,
    );
    add(_borderComponent);

    parallaxComponent = await _loadParallaxComponent();
    add(parallaxComponent);

    _updateResponsivePositions(force: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    isVisible = scene.active;

    final rateText = _formatRate(scene.generationRatePerSecond);
    if (_lastRateText != rateText) {
      _lastRateText = rateText;
      rateComponent.text = rateText;
    }

    if (scene.active) {
      onSceneActive(dt);
    } else {
      onSceneInactive(dt);
    }

    _updateResponsivePositions();
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
    onSceneTap();
  }

  String _formatRate(double rate) =>
      '(${game.text.per_second_indicator(rate.toStringAsPrecision(3))})';

  Future<ParallaxComponent> _loadParallaxComponent() {
    return game.loadParallaxComponent(
      _parallaxImages,
      size: size.clone(),
      baseVelocity: Vector2.zero(),
      velocityMultiplierDelta: Vector2(1.5, 1.0),
    );
  }

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

  void onSceneActive(double dt);

  void onSceneInactive(double dt);

  void onSceneTap();
}
