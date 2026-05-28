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

  void restoreHealth(double amount) {
    if (amount <= 0) return;

    health = (health + amount).clamp(0.0, maxHealth);
  }

  void restoreStamina(double amount) {
    if (amount <= 0) return;

    stamina = (stamina + amount).clamp(0.0, maxStamina);
  }

  WorkerModel copyWith({
    double? damage,
    double? maxHealth,
    double? health,
    double? maxStamina,
    double? staminaCostPerAttack,
    double? stamina,
    IconData? icon,
    IconData? toolsIcon,
  }) {
    return WorkerModel(
      damage: damage ?? this.damage,
      maxHealth: maxHealth ?? this.maxHealth,
      maxStamina: maxStamina ?? this.maxStamina,
      staminaCostPerAttack: staminaCostPerAttack ?? this.staminaCostPerAttack,
      health: health ?? this.health,
      stamina: stamina ?? this.stamina,
      icon: icon ?? this.icon,
      toolsIcon: toolsIcon ?? this.toolsIcon,
    );
  }
}
