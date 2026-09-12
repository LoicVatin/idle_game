import 'package:flutter/material.dart';

import 'package:idle_game/core/styles/app_colors.dart';

enum ResourceType {
  food(icon: Icons.grass_outlined, color: AppColors.red),
  wood(icon: Icons.forest_outlined, color: AppColors.darkBrown),
  stone(icon: Icons.landscape_outlined, color: AppColors.lightGrey);

  const ResourceType({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

class Resource {
  final ResourceType type;
  double amount;

  Resource({required this.type, this.amount = 0.0});

  Resource copyWith({ResourceType? type, double? amount}) {
    return Resource(type: type ?? this.type, amount: amount ?? this.amount);
  }

  void add(double value) => amount += value;

  void subtract(double value) {
    amount = (amount - value).clamp(0.0, double.infinity);
  }

  void reset() {
    amount = 0.0;
  }
}
