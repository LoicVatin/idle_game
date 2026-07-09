import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/component_utils.dart';
import 'package:idle_game/data/models/creature/creature_state.dart';
import 'package:idle_game/core/game/components/creature/sprite_animation_with_states_component.dart';
import 'package:idle_game/core/game/components/creature/status_bar_component.dart';
import 'package:idle_game/core/game/components/creature/status_text_component.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/creature/creature_model.dart';
import 'package:idle_game/data/models/scene_model.dart';
import 'package:idle_game/core/styles/app_colors.dart';

enum StatusOrder { statusHealthStamina, staminaStatusHealth }

abstract class CreatureComponent<T extends CreatureModel>
    extends RectangleComponent
    with HasGameReference<IdleGame>, CollisionCallbacks, HasVisibility {
  final CollisionType collisionType;
  final T model;
  bool isInConfrontation = false;
  double timer = 0;

  int _lastLevel = -1;
  double lastHealth = -1;
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

  static final double componentRadius = Dimensions.large;
  static final double componentHalfRadius = componentRadius / 2;

  final Color color;
  final StatusOrder statusOrder;
  final Anchor primaryIconAnchor;
  final Anchor secondaryIconAnchor;

  final String defaultSpriteSheetFolder = "";
  final String defaultSpriteSheet = "test_card";

  CreatureComponent({
    required this.model,
    this.collisionType = CollisionType.active,
    super.position,
    super.anchor,
    super.priority,
    this.color = AppColors.yellow,
    this.statusOrder = StatusOrder.statusHealthStamina,
    this.primaryIconAnchor = Anchor.bottomCenter,
    this.secondaryIconAnchor = Anchor.topCenter,
  }) : super(
         size: Vector2.all(componentRadius),
         paint: Paint()..color = color.withValues(alpha: 0.3),
       ) {
    statusText = StatusTextComponent();
    healthBar = StatusBarComponent(fillColor: AppColors.green);
    staminaBar = StatusBarComponent(fillColor: AppColors.yellow);
    spriteAnimationComponent = SpriteAnimationWithStatesComponent(
      name:
          "$defaultSpriteSheetFolder${model.spriteSheet ?? defaultSpriteSheet}",
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
        paint: Paint()..color = AppColors.light.withValues(alpha: 0.3),
      ),
      IconComponent(
        icon: model.secondaryIcon,
        size: Vector2.all(componentHalfRadius),
        anchor: secondaryIconAnchor,
        position: Vector2.all(componentHalfRadius),
        paint: Paint()..color = AppColors.light.withValues(alpha: 0.3),
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

  @override
  void update(double dt) {
    super.update(dt);
    model.update(dt);
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

    if (lastHealth == model.health &&
        _lastHealthSceneId == scene.id &&
        _lastHealthAlwaysVisible == alwaysVisible) {
      return;
    }
    lastHealth = model.health;
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

  void updateCreatureState(double dt) {
    updateStatusText();
    updateHealthBar();
    updateStaminaBar();
  }

  void onConfrontation() {
    isInConfrontation = true;
    state = CreatureState.attack;
    timer = CreatureModel.confrontationStepDuration;
    paint.color = AppColors.darkYellow.withValues(alpha: 0.3);
    updateHealthBar();
    updateStaminaBar();
  }

  void moveOnClick() {
    clickBoostTime = CreatureModel.clickBoostDuration;
  }

  SceneModel get scene;

  CreatureState get state => model.state;

  set state(CreatureState value) {
    model.state = value;
    if (spriteAnimationComponent.state == value) return;
    spriteAnimationComponent.state = value;
  }

  double get clickBoostTime => model.clickBoostTime;

  set clickBoostTime(double value) => model.clickBoostTime = value;

  bool isStatusAlwaysVisible();

  bool isHealthBarAlwaysVisible();

  bool isStaminaBarAlwaysVisible();

  void defeat();
}
