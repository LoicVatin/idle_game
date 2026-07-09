import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/core/game/components/component_utils.dart';

import 'package:idle_game/core/styles/app_colors.dart';

class StatusTextComponent extends RectangleComponent
    with HasGameReference<IdleGame>, HasVisibility {
  static final double statusBarWidth = Dimensions.large;
  static final double statusBarHeight = Dimensions.tiny;

  late final TextComponent nameText;
  late final TextComponent levelText;

  StatusTextComponent({super.key, super.position})
    : super(
        size: Vector2(statusBarWidth, statusBarHeight),
        paint: Paint()..color = AppColors.dark.withValues(alpha: 0.5),
        children: [
          RowComponent(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            size: Vector2(statusBarWidth, statusBarHeight),
            gap: Dimensions.extraSmall,
            anchor: Anchor.center,
            position: Vector2(statusBarWidth / 2, statusBarHeight / 2),
            children: [
              TextComponent(
                //anchor: Anchor.centerLeft,
                //position: Vector2(statusBarWidth/2, statusBarHeight/2),
                //size: Vector2(statusBarWidth, statusBarHeight),
              ),
              TextComponent(
                //anchor: Anchor.centerLeft,
                //position: Vector2(statusBarWidth/2, statusBarHeight/2),
                //size: Vector2(statusBarWidth, statusBarHeight),
              ),
            ],
          ),
        ],
      ) {
    final statusTexts = children
        .whereType<RowComponent>()
        .first
        .children
        .whereType<TextComponent>()
        .toList();

    nameText = statusTexts[0];
    levelText = statusTexts[1];
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    nameText.textRenderer = TextPaint(style: game.textTheme.labelSmall);
    levelText.textRenderer = TextPaint(style: game.textTheme.labelSmall);
  }

  void updateStatusText(String name, int level, {bool alwaysVisible = true}) {
    nameText.text = name;
    levelText.text = level.toStringAsPrecision(3);
    isVisible = alwaysVisible;
  }
}
