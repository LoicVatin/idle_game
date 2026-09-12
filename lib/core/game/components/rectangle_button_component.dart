import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/component_utils.dart';
import 'package:idle_game/core/game/components/hold_button_component.dart';
import 'package:idle_game/core/styles/app_colors.dart';

class RectangleButtonComponent extends HoldableButtonComponent {
  RectangleButtonComponent({
    required IconData icon,
    super.onPressed,
    super.onHold,
    super.anchor,
    super.position,
    double radius = Dimensions.medium,
    bool outlined = false,
  }) : super(
         size: Vector2.all(radius * 2),
         defaultSkin: RectangleButtonFace(
           icon: icon,
           color: AppColors.accent,
           radius: radius,
           outlined: outlined,
         ),
         downSkin: RectangleButtonFace(
           icon: icon,
           color: AppColors.antiqueGold,
           radius: radius,
           outlined: outlined,
         ),
         disabledSkin: RectangleButtonFace(
           icon: icon,
           color: AppColors.grey,
           radius: radius,
           outlined: outlined,
         ),
       );
}

class RectangleButtonFace extends RectangleComponent with IconButtonFaceMixin {
  RectangleButtonFace({
    required IconData icon,
    required Color color,
    required double radius,
    required bool outlined,
  }) : super(size: Vector2.all(radius * 2), paint: Paint()..color = color) {
    initializeIconPainter(icon: icon, radius: radius);
    if (outlined) {
      add(
        RectangleComponent(
          size: super.size,
          paint: Paint()
            ..color = AppColors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
          priority: Priorities.overlay,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderIcon(canvas);
  }
}
