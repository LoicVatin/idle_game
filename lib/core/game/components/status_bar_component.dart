import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class StatusBarComponent extends RectangleComponent with HasVisibility {
  static const double statusBarWidth = 42;
  static const double statusBarHeight = 5;
  static const double statusBarGap = 3;

  late final RectangleComponent statusBarFill;
  final Color fillColor;

  StatusBarComponent({super.position, this.fillColor = Colors.yellowAccent})
    : super(
        size: Vector2(statusBarWidth, statusBarHeight),
        paint: Paint()..color = Colors.black54,
        children: [
          RectangleComponent(
            size: Vector2(statusBarWidth, statusBarHeight),
            paint: Paint()..color = fillColor,
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
    statusBarFill.size.x = statusBarWidth * fillPercent;
    isVisible = currentValue < maxValue || alwaysVisible;
  }
}
