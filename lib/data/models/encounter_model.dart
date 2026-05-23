import 'package:flutter/material.dart';
import 'package:idle_game/data/models/resource_model.dart';

class EncounterModel {
  final ResourceType type;
  final double health;
  final double reward;
  final IconData icon;

  EncounterModel({
    required this.type,
    required this.health,
    required this.reward,
    required this.icon,
  });

  EncounterModel copyWith({
    ResourceType? type,
    double? health,
    double? reward,
    IconData? icon,
  }) {
    return EncounterModel(
      type: type ?? this.type,
      health: health ?? this.health,
      reward: reward ?? this.reward,
      icon: icon ?? this.icon,
    );
  }
}
