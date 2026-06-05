import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/data/models/resource_model.dart';

class ResourceCostComponent extends PositionComponent {
  Resource _resource;
  double _upgradeCost;
  late final TextComponent _amountTextComponent;

  double _lastAmount = -1;
  double _lastUpgradeCost = -1;

  Resource get resource => _resource;

  set resource(Resource value) {
    _resource = value;
    if (_lastAmount != value.amount) {
      _lastAmount = value.amount;
      //_amountTextComponent.text = _formatAmount(value.amount);
    }
  }

  set upgradeCost(num value) {
    _upgradeCost = value.toDouble();
    if (_lastUpgradeCost != value.toDouble()) {
      _lastUpgradeCost = value.toDouble();
      _amountTextComponent.text = _formatAmount(value.toDouble());
    }
  }

  ResourceCostComponent({
    required Resource resource,
    required double upgradeCost,
  }) : _resource = resource,
       _upgradeCost = upgradeCost,
       super(size: Vector2(60, 12));

  @override
  Future<void> onLoad() async {
    _amountTextComponent = TextComponent(
      text: _formatAmount(_upgradeCost),
      size: Vector2(50, 12),
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 16.0, color: BasicPalette.white.color),
      ),
    );

    add(
      RowComponent(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        gap: 8,
        size: Vector2(size.x, 12),
        children: [
          IconComponent(icon: _resource.type.icon, size: Vector2.all(12)),
          _amountTextComponent,
        ],
      ),
    );

    return super.onLoad();
  }

  String _formatAmount(double amount) => amount.toStringAsPrecision(3);
}
