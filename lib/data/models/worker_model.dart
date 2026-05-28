import 'package:flutter/cupertino.dart';

class WorkerModel {
  final double damage;
  final double maxStamina;
  final double maxHealth;
  double health;
  double stamina;
  final double staminaCostPerAttack;
  final IconData icon;
  final IconData toolsIcon;

  WorkerModel({
    this.damage = 1,
    this.maxHealth = 100,
    this.maxStamina = 50,
    this.staminaCostPerAttack = 1,
    double? health,
    double? stamina,
    required this.icon,
    required this.toolsIcon,
  }) : health = health ?? maxHealth,
       stamina = stamina ?? maxStamina;

  bool get canAttack => stamina >= staminaCostPerAttack;

  bool spendAttackStamina() {
    if (!canAttack) {
      return false;
    }

    stamina = (stamina - staminaCostPerAttack).clamp(0.0, maxStamina);
    return true;
  }

  WorkerModel copyWith({
    double? damage,
    double? maxStamina,
    double? staminaCostPerAttack,
    double? stamina,
    IconData? icon,
    IconData? toolsIcon,
  }) {
    return WorkerModel(
      damage: damage ?? this.damage,
      maxStamina: maxStamina ?? this.maxStamina,
      staminaCostPerAttack: staminaCostPerAttack ?? this.staminaCostPerAttack,
      stamina: stamina ?? this.stamina,
      icon: icon ?? this.icon,
      toolsIcon: toolsIcon ?? this.toolsIcon,
    );
  }
}
