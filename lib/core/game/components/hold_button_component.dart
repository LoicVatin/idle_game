import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

abstract class HoldableButtonComponent extends AdvancedButtonComponent {
  HoldableButtonComponent({
    required super.size,
    required super.onPressed,
    required super.defaultSkin,
    required super.downSkin,
    required super.disabledSkin,
    this.onHold,
  });

  static const double holdDelay = 0.5;
  static const double holdInterval = 0.25;

  final VoidCallback? onHold;

  bool _isHolding = false;
  double _holdTimer = 0;
  double _holdRepeatTimer = 0;

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _startHolding();
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    _stopHolding();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    _stopHolding();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final holdCallback = onHold ?? onPressed;
    if (!_isHolding || holdCallback == null) {
      return;
    }

    _holdTimer += dt;
    if (_holdTimer < holdDelay) {
      return;
    }

    _holdRepeatTimer += dt;
    if (_holdRepeatTimer < holdInterval) {
      return;
    }

    _holdRepeatTimer %= holdInterval;
    holdCallback();
  }

  void _startHolding() {
    _isHolding = true;
    _holdTimer = 0;
    _holdRepeatTimer = 0;
  }

  void _stopHolding() {
    _isHolding = false;
    _holdTimer = 0;
    _holdRepeatTimer = 0;
  }
}

mixin IconButtonFaceMixin on PositionComponent {
  late final TextPainter _iconPainter;
  late final Offset _iconOffset;

  void initializeIconPainter({
    required IconData icon,
    required double radius,
    Color iconColor = Colors.white,
  }) {
    _iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: radius,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    _iconOffset = Offset(
      radius - _iconPainter.width / 2,
      radius - _iconPainter.height / 2,
    );
  }

  void renderIcon(Canvas canvas) {
    _iconPainter.paint(canvas, _iconOffset);
  }
}
