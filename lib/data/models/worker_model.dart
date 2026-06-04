import 'dart:math';

import 'package:flutter/cupertino.dart';

class WorkerModel {
  double damage;
  double maxStamina;
  double maxHealth;
  double health;
  double stamina;
  double experience;
  int level;
  final int maxLevel;
  final double x = 0.1;
  final double y = 2.0;
  final double staminaCostPerAttack;
  final IconData icon;
  final IconData toolsIcon;

  WorkerModel({
    this.damage = 1,
    this.maxHealth = 100,
    this.maxStamina = 50,
    this.level = 1,
    this.maxLevel = 100,
    this.staminaCostPerAttack = 1,
    double? health,
    double? stamina,
    double? experience,
    required this.icon,
    required this.toolsIcon,
  }) : health = health ?? maxHealth,
       stamina = stamina ?? maxStamina,
       experience = experience ?? 0;

  bool get canAttack => stamina >= staminaCostPerAttack;

  bool get isAlive => health > 0;

  bool spendAttackStamina() {
    if (!canAttack) {
      return false;
    }

    stamina = (stamina - staminaCostPerAttack).clamp(0.0, maxStamina);
    return true;
  }

  void takeDamage(double amount) {
    if (amount <= 0) return;

    health = (health - amount).clamp(0.0, maxHealth);
  }

  void restoreHealth(double amount) {
    if (amount <= 0) return;

    health = (health + amount).clamp(0.0, maxHealth);
  }

  void restoreStamina(double amount) {
    if (amount <= 0) return;

    stamina = (stamina + amount).clamp(0.0, maxStamina);
  }

  num get experienceNeeded => pow((level.toDouble() / x), y);

  bool canLevelUp() {
    return experience >= experienceNeeded && level < maxLevel;
  }

  void levelUp() {
    experience -= experienceNeeded;
    level++;
    damage += 1;
    maxHealth += 25;
    maxStamina += 10;
  }

  void levelDown() {
    experience = 0;
    level--;
    damage -= 1;
    maxHealth -= 25;
    maxStamina -= 10;
  }

  void addExperience(double baseReward) {
    experience += baseReward;
    if (canLevelUp()) {
      levelUp();
    }
  }

  void resetExperience() {
    experience = 0;
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
