import 'package:flutter/material.dart';

enum ResourceType {
  food(icon: Icons.grass_outlined, color: Colors.redAccent),
  wood(icon: Icons.forest_outlined, color: Colors.brown),
  stone(icon: Icons.landscape_outlined, color: Colors.blueGrey);

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
