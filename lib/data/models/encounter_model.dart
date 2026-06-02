import 'package:flutter/material.dart';
import 'package:idle_game/data/models/resource_model.dart';

class EncounterModel {
  final ResourceType type;
  final double health;
  final double damage;
  final double reward;
  final IconData icon;

  EncounterModel({
    required this.type,
    required this.health,
    this.damage = 0,
    required this.reward,
    required this.icon,
  });

  EncounterModel copyWith({
    ResourceType? type,
    double? health,
    double? damage,
    double? reward,
    IconData? icon,
  }) {
    return EncounterModel(
      type: type ?? this.type,
      health: health ?? this.health,
      damage: damage ?? this.damage,
      reward: reward ?? this.reward,
      icon: icon ?? this.icon,
    );
  }
}
