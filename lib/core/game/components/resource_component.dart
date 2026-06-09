import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/resource_model.dart';

class ResourceComponent extends RectangleComponent
    with HasGameReference<IdleGame> {
  Resource _resource;
  final TextComponent _amountTextComponent = TextComponent();

  final EdgeInsets padding;

  double _lastAmount = -1;

  Resource get resource => _resource;

  set resource(Resource value) {
    _resource = value;
    if (_lastAmount != value.amount) {
      _lastAmount = value.amount;
      _amountTextComponent.text = _formatAmount(value.amount);
    }
  }

  ResourceComponent({
    required Resource resource,
    this.padding = const EdgeInsets.all(8),
  }) : _resource = resource,
       super(
         size: Vector2(120, 24 + padding.vertical),
         paint: Paint()..color = resource.type.color,
       );

  @override
  Future<void> onLoad() async {
    _amountTextComponent
      ..text = _formatAmount(_resource.amount)
      ..size = Vector2(50, 24)
      ..textRenderer = TextPaint(style: game.textTheme.bodyLarge);

    add(
      RowComponent(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        gap: 10,
        position: Vector2(padding.left, padding.top),
        size: Vector2(size.x - padding.horizontal, 24),
        children: [
          IconComponent(icon: _resource.type.icon, size: Vector2.all(24)),
          _amountTextComponent,
        ],
      ),
    );

    return super.onLoad();
  }

  String _formatAmount(double amount) => amount.toStringAsPrecision(3);
}
