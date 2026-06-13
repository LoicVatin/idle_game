import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/creature/sprite_animation_with_states_component.dart';
import 'package:idle_game/core/game/components/creature/status_bar_component.dart';
import 'package:idle_game/core/game/components/creature/status_text_component.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/creature/creature_model.dart';
import 'package:idle_game/data/models/scene_model.dart';

enum StatusOrder { statusHealthStamina, staminaStatusHealth }

abstract class CreatureComponent<T extends CreatureModel>
    extends RectangleComponent
    with HasGameReference<IdleGame>, CollisionCallbacks, HasVisibility {
  final CollisionType collisionType;
  final T model;
  bool isInConfrontation = false;
  double timer = 0;

  AnimationState state = AnimationState.idle;

  int _lastLevel = -1;
  double _lastHealth = -1;
  double _lastStamina = -1;
  int? _lastStatusSceneId;
  int? _lastHealthSceneId;
  int? _lastStaminaSceneId;
  bool? _lastStatusAlwaysVisible;
  bool? _lastHealthAlwaysVisible;
  bool? _lastStaminaAlwaysVisible;

  late final StatusTextComponent statusText;
  late final StatusBarComponent healthBar;
  late final StatusBarComponent staminaBar;
  late final SpriteAnimationWithStatesComponent spriteAnimationComponent;

  double clickBoostTime = 0;
  static const double clickBoostDuration = 0.6;
  static const double clickBoostVelocity = 30;

  static const double componentRadius = 48.0;
  static const double componentHalfRadius = componentRadius / 2;
  static const double confrontationStepDuration = 0.15;
  static const double confrontationAttackInterval = 0.35;

  final Color color;
  final StatusOrder statusOrder;
  final Anchor primaryIconAnchor;
  final Anchor secondaryIconAnchor;

  CreatureComponent({
    required this.model,
    this.collisionType = CollisionType.active,
    super.position,
    super.anchor,
    super.priority = 50,
    this.color = Colors.yellowAccent,
    this.statusOrder = StatusOrder.statusHealthStamina,
    this.primaryIconAnchor = Anchor.bottomCenter,
    this.secondaryIconAnchor = Anchor.topCenter,
  }) : super(
         size: Vector2.all(componentRadius),
         paint: Paint()..color = color,
       ) {
    statusText = StatusTextComponent();
    healthBar = StatusBarComponent(fillColor: Colors.greenAccent);
    staminaBar = StatusBarComponent(fillColor: Colors.orangeAccent);
    spriteAnimationComponent = SpriteAnimationWithStatesComponent(
      size: Vector2.all(componentRadius),
      position: Vector2.zero(),
    );

    addAll([
      ColumnComponent(
        size: Vector2(componentRadius, componentHalfRadius),
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        anchor: Anchor.bottomLeft,
        gap: StatusBarComponent.statusBarHeight,
        children: [
          ...switch (statusOrder) {
            StatusOrder.statusHealthStamina => [
              statusText,
              healthBar,
              staminaBar,
            ],
            StatusOrder.staminaStatusHealth => [
              staminaBar,
              statusText,
              healthBar,
            ],
          },
        ],
      ),
      IconComponent(
        icon: model.primaryIcon,
        size: Vector2.all(componentHalfRadius),
        anchor: primaryIconAnchor,
        position: Vector2.all(componentHalfRadius),
      ),
      IconComponent(
        icon: model.secondaryIcon,
        size: Vector2.all(componentHalfRadius),
        anchor: secondaryIconAnchor,
        position: Vector2.all(componentHalfRadius),
      ),
      spriteAnimationComponent,
    ]);
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(collisionType: collisionType));

    updateStatusText();
    updateHealthBar();
    updateStaminaBar();
  }

  void updateStatusText() {
    final alwaysVisible = isStatusAlwaysVisible();

    if (_lastLevel == model.level &&
        _lastStatusSceneId == scene.id &&
        _lastStatusAlwaysVisible == alwaysVisible) {
      return;
    }
    _lastLevel = model.level;
    _lastStatusSceneId = scene.id;
    _lastStatusAlwaysVisible = alwaysVisible;

    statusText.updateStatusText(
      model.name,
      model.level,
      alwaysVisible: alwaysVisible,
    );
  }

  void updateHealthBar() {
    final alwaysVisible = isHealthBarAlwaysVisible();

    if (_lastHealth == model.health &&
        _lastHealthSceneId == scene.id &&
        _lastHealthAlwaysVisible == alwaysVisible) {
      return;
    }
    _lastHealth = model.health;
    _lastHealthSceneId = scene.id;
    _lastHealthAlwaysVisible = alwaysVisible;

    healthBar.updateStatusBar(
      model.health,
      model.maxHealth,
      alwaysVisible: alwaysVisible,
    );
  }

  void updateStaminaBar() {
    final alwaysVisible = isStaminaBarAlwaysVisible();

    if (_lastStamina == model.stamina &&
        _lastStaminaSceneId == scene.id &&
        _lastStaminaAlwaysVisible == alwaysVisible) {
      return;
    }
    _lastStamina = model.stamina;
    _lastStaminaSceneId = scene.id;
    _lastStaminaAlwaysVisible = alwaysVisible;

    staminaBar.updateStatusBar(
      model.stamina,
      model.maxStamina,
      alwaysVisible: alwaysVisible,
    );
  }

  SceneModel get scene;

  bool isStatusAlwaysVisible();

  bool isHealthBarAlwaysVisible();

  bool isStaminaBarAlwaysVisible();

  void moveOnClick();

  void defeat();
}
