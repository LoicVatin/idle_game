import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/hold_button_component.dart';

class RectangleButtonComponent extends HoldableButtonComponent {
  RectangleButtonComponent({
    required IconData icon,
    super.onPressed,
    super.onHold,
    super.anchor,
    super.position,
    double radius = 24,
  }) : super(
         size: Vector2.all(radius * 2),
         defaultSkin: RectangleButtonFace(
           icon: icon,
           color: Colors.deepPurple,
           radius: radius,
         ),
         downSkin: RectangleButtonFace(
           icon: icon,
           color: Colors.deepPurpleAccent,
           radius: radius,
         ),
         disabledSkin: RectangleButtonFace(
           icon: icon,
           color: Colors.blueGrey,
           radius: radius,
         ),
       );
}

class RectangleButtonFace extends RectangleComponent with IconButtonFaceMixin {
  RectangleButtonFace({
    required IconData icon,
    required Color color,
    required double radius,
  }) : super(size: Vector2.all(radius * 2), paint: Paint()..color = color) {
    initializeIconPainter(icon: icon, radius: radius);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderIcon(canvas);
  }
}
