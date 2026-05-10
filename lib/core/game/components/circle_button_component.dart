import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class CircleButtonComponent extends ButtonComponent {
  final IconData icon;
  final double radius;

  CircleButtonComponent({
    required this.icon,
    required VoidCallback onPressed,
    this.radius = 24,
  }) : super(
         size: Vector2.all(radius * 2),
         onPressed: onPressed,
         button: CircleButtonFace(
           icon: icon,
           color: Colors.deepPurple,
           radius: radius,
         ),
         buttonDown: CircleButtonFace(
           icon: icon,
           color: Colors.deepPurpleAccent,
           radius: radius,
         ),
       );
}

class CircleButtonFace extends CircleComponent {
  final IconData icon;
  final Color color;

  CircleButtonFace({
    required this.icon,
    required this.color,
    required super.radius,
  }) : super(paint: Paint()..color = color);

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
