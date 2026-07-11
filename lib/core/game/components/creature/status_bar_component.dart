import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/component_utils.dart';

import 'package:idle_game/core/styles/app_colors.dart';

class StatusBarComponent extends RectangleComponent with HasVisibility {
  static final double statusBarWidth = Dimensions.large;
  static final double statusBarHeight = Dimensions.tiny;

  late final RectangleComponent statusBarFill;
  final Color fillColor;

  StatusBarComponent({
    super.key,
    super.position,
    this.fillColor = AppColors.yellow,
  }) : super(
         size: Vector2(statusBarWidth, statusBarHeight),
         paint: Paint()..color = AppColors.dark.withValues(alpha: 0.5),
         children: [
           RectangleComponent(
             size: Vector2(statusBarWidth - 4, statusBarHeight - 4),
             position: Vector2.all(2),
             paint: Paint()..color = fillColor,
           ),
           RectangleComponent(
             size: Vector2(statusBarWidth, statusBarHeight),
             paint: Paint()
               ..color = AppColors.dark
               ..style = PaintingStyle.stroke
               ..strokeWidth = 2,
             priority: Priorities.overlay,
           ),
         ],
       ) {
    final statusBars = children.whereType<RectangleComponent>().toList();

    statusBarFill = statusBars[0];
  }

  void updateStatusBar(
    double currentValue,
    double maxValue, {
    bool alwaysVisible = false,
  }) {
    final fillPercent = maxValue <= 0
        ? 0.0
        : (currentValue / maxValue).clamp(0.0, 1.0);
    statusBarFill.size.x = (statusBarWidth - 4) * fillPercent;
    isVisible = currentValue < maxValue || alwaysVisible;
  }
}
