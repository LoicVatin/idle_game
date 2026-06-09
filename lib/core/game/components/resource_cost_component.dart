import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/layout.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/data/models/resource_model.dart';

class ResourceCostComponent extends PositionComponent
    with HasGameReference<IdleGame> {
  Resource _resource;
  double _upgradeCost;
  final TextComponent _amountTextComponent = TextComponent();

  double _lastAmount = -1;
  double _lastUpgradeCost = -1;
  Color? _originalColor;

  Resource get resource => _resource;

  set resource(Resource value) {
    _resource = value;
    if (_lastAmount != value.amount) {
      _lastAmount = value.amount;
      _updateStyle();
    }
  }

  set upgradeCost(num value) {
    _upgradeCost = value.toDouble();
    if (_lastUpgradeCost != value.toDouble()) {
      _lastUpgradeCost = value.toDouble();
      _amountTextComponent.text = _formatAmount(value.toDouble());
      _updateStyle();
    }
  }

  void _updateStyle() {
    if (_amountTextComponent.textRenderer is TextPaint) {
      final textPaint = _amountTextComponent.textRenderer as TextPaint;
      _originalColor ??= textPaint.style.color;

      final canAfford = _resource.amount >= _upgradeCost;
      final targetColor = canAfford ? _originalColor : Colors.red;

      if (textPaint.style.color != targetColor) {
        _amountTextComponent.textRenderer = TextPaint(
          style: textPaint.style.copyWith(color: targetColor),
        );
      }
    }
  }

  ResourceCostComponent({
    required Resource resource,
    required double upgradeCost,
  }) : _resource = resource,
       _upgradeCost = upgradeCost,
       super(size: Vector2(80, 12));

  @override
  Future<void> onLoad() async {
    _amountTextComponent
      ..text = _formatAmount(_upgradeCost)
      ..size = Vector2(80, 12)
      ..textRenderer = TextPaint(style: game.textTheme.bodyLarge);

    add(
      RowComponent(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        gap: 8,
        size: Vector2(size.x, 12),
        children: [
          AlignComponent(alignment: Anchor.center, child: _amountTextComponent),
          IconComponent(icon: _resource.type.icon, size: Vector2.all(12)),
        ],
      ),
    );

    return super.onLoad();
  }

  String _formatAmount(double amount) => amount.toStringAsPrecision(3);
}
