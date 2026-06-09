import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/hold_button_component.dart';

class CircleButtonComponent extends HoldableButtonComponent {
  CircleButtonComponent({
    required IconData icon,
    super.onPressed,
    super.onHold,
    super.anchor,
    super.position,
    double radius = 24,
  }) : super(
         size: Vector2.all(radius * 2),
         defaultSkin: CircleButtonFace(
           icon: icon,
           color: Colors.deepPurple,
           radius: radius,
         ),
         downSkin: CircleButtonFace(
           icon: icon,
           color: Colors.deepPurpleAccent,
           radius: radius,
         ),
         disabledSkin: CircleButtonFace(
           icon: icon,
           color: Colors.blueGrey,
           radius: radius,
         ),
       );
}

class CircleButtonFace extends CircleComponent with IconButtonFaceMixin {
  CircleButtonFace({
    required IconData icon,
    required Color color,
    required double radius,
  }) : super(radius: radius, paint: Paint()..color = color) {
    initializeIconPainter(icon: icon, radius: radius);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderIcon(canvas);
  }
}
