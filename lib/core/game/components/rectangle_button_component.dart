import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class ClickableRectangleComponent extends RectangleComponent with TapCallbacks {
  ClickableRectangleComponent({
    required IconData icon,
    required this.onPressed,
    double radius = 24,
  }) : super(
         size: Vector2.all(radius * 2),
         paint: Paint()..color = Colors.deepPurple,
         children: [
           IconComponent(
             icon: icon,
             size: Vector2.all(radius),
             anchor: Anchor.center,
             position: Vector2.all(radius),
           ),
         ],
       );

  final VoidCallback onPressed;

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
    event.handled = true;
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    onPressed();
    event.handled = true;
  }
}

class RectangleButtonComponent extends ButtonComponent {
  final IconData icon;
  final double radius;

  RectangleButtonComponent({
    required this.icon,
    required VoidCallback onPressed,
    this.radius = 24,
  }) : super(
         size: Vector2.all(radius * 2),
         onPressed: onPressed,
         button: RectangleButtonFace(
           icon: icon,
           color: Colors.deepPurple,
           radius: radius,
         ),
         buttonDown: RectangleButtonFace(
           icon: icon,
           color: Colors.deepPurpleAccent,
           radius: radius,
         ),
       );
}

class RectangleButtonFace extends RectangleComponent {
  final IconData icon;
  final Color color;
  final double radius;

  RectangleButtonFace({
    required this.icon,
    required this.color,
    required this.radius,
  }) : super(paint: Paint()..color = color, size: Vector2.all(radius * 2));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: radius,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );
  }
}
