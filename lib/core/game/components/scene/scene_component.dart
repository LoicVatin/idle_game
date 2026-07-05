import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
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

  late Parallax _parallax;
  bool _isReloadingParallax = false;

  static final Vector2 _velocityMultiplierDelta = Vector2(1.5, 1.0);

  String get _spriteSheetName =>
      'backgrounds_${scene.spriteSheet ?? defaultSpriteSheet}';

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
      priority: Priorities.overlay,
      textRenderer: TextPaint(style: game.textTheme.titleLarge),
    );
    add(_nameComponent);

    rateComponent = TextComponent(
      anchor: Anchor.bottomRight,
      text: _lastRateText,
      position: Vector2(width - padding, height - padding),
      priority: Priorities.overlay,
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

    _parallax = await _buildParallax();
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

  Future<ParallaxComponent> _loadParallaxComponent() async {
    return ParallaxComponent(
      parallax: _parallax..size = size.clone(),
      size: size.clone(),
      priority: Priorities.background,
    );
  }

  /// Builds an animated parallax from the aseprite sprite sheet
  /// (`<name>.png` + `<name>.json`) located in [defaultSpriteSheetFolder].
  ///
  /// Each aseprite layer becomes one animated parallax layer: the frames that
  /// belong to a layer (the name inside parentheses in the frame key) are
  /// grouped into a [SpriteAnimation] and rendered through a [ParallaxAnimation].
  /// Layers are kept in the sheet's back-to-front order so the closer a layer
  /// is, the faster it moves ([_velocityMultiplierDelta] ^ depth).
  Future<Parallax> _buildParallax() async {
    final image = await Flame.images.load(
      '$defaultSpriteSheetFolder$_spriteSheetName.png',
    );
    final jsonData = await Flame.assets.readJson(
      'images/$defaultSpriteSheetFolder$_spriteSheetName.json',
    );

    final sheetAnimation = SpriteAnimation.fromAsepriteData(image, jsonData);
    final frames = sheetAnimation.frames;

    final frameKeys = (jsonData['frames'] as Map<String, dynamic>).keys
        .toList();
    final layerOrder = <String>[];
    final layerRanges = <String, List<int>>{};
    for (var i = 0; i < frameKeys.length; i++) {
      final layerName = _layerNameFromFrameKey(frameKeys[i]);
      final range = layerRanges[layerName];
      if (range == null) {
        layerOrder.add(layerName);
        layerRanges[layerName] = [i, i + 1];
      } else {
        range[1] = i + 1;
      }
    }

    final layers = <ParallaxLayer>[];
    for (var depth = 0; depth < layerOrder.length; depth++) {
      final range = layerRanges[layerOrder[depth]]!;
      final animation = SpriteAnimation(frames.sublist(range[0], range[1]));
      final prerenderedFrames = animation.frames
          .map((frame) => frame.sprite.toImageSync())
          .toList();
      layers.add(
        ParallaxLayer(
          ParallaxAnimation(animation, prerenderedFrames),
          velocityMultiplier: _velocityMultiplierForDepth(depth),
        ),
      );
    }

    return Parallax(layers, size: size.clone(), baseVelocity: Vector2.zero());
  }

  /// Extracts the aseprite layer name embedded between parentheses in a frame
  /// key, e.g. `backgrounds_template (sky_5) 0.aseprite` -> `sky_5`.
  String _layerNameFromFrameKey(String key) {
    final start = key.indexOf('(');
    final end = key.indexOf(')', start + 1);
    if (start == -1 || end == -1) {
      return key;
    }
    return key.substring(start + 1, end);
  }

  /// Mirrors Flame's `Parallax.load` velocity computation:
  /// `_velocityMultiplierDelta ^ (depth + 1)`.
  Vector2 _velocityMultiplierForDepth(int depth) {
    final multiplier = _velocityMultiplierDelta.clone();
    for (var i = 0; i < depth; i++) {
      multiplier.multiply(_velocityMultiplierDelta);
    }
    return multiplier;
  }

  Future<void> _reloadParallaxAfterResize() async {
    if (_isReloadingParallax || isRemoved) {
      return;
    }

    _isReloadingParallax = true;

    final oldParallaxComponent = parallaxComponent;

    final newParallaxComponent = await _loadParallaxComponent();

    if (isRemoved) {
      newParallaxComponent.removeFromParent();
      _isReloadingParallax = false;
      return;
    }

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
