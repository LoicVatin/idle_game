import 'dart:math';

import 'package:flutter/cupertino.dart';

abstract class CreatureModel {
  final String name;
  final IconData primaryIcon;
  final IconData secondaryIcon;

  int level;
  final int maxLevel;
  double experience;
  final double x = 0.1;
  final double y = 2.0;

  double maxHealth;
  double health;
  double healthIncreasePerLevel;

  double maxStamina;
  double stamina;
  double staminaIncreasePerLevel;

  double damage;
  double damageIncreasePerLevel;
  double staminaCostPerAttack;

  CreatureModel({
    required this.name,
    required this.primaryIcon,
    required this.secondaryIcon,
    this.level = 1,
    this.maxLevel = 100,
    double? experience,
    this.maxHealth = 100,
    double? health,
    this.healthIncreasePerLevel = 25,
    this.maxStamina = 50,
    double? stamina,
    this.staminaIncreasePerLevel = 10,
    this.damage = 1,
    this.damageIncreasePerLevel = 1,
    this.staminaCostPerAttack = 1,
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

  num get experienceNeededToLevelUp => pow((level.toDouble() / x), y);

  bool canLevelUp() {
    return experience >= experienceNeededToLevelUp && level < maxLevel;
  }

  void levelUp() {
    experience -= experienceNeededToLevelUp;
    level++;
    damage += damageIncreasePerLevel;
    maxHealth += healthIncreasePerLevel;
    maxStamina += staminaIncreasePerLevel;
  }

  void levelDown() {
    experience = 0;
    level--;
    damage -= damageIncreasePerLevel;
    maxHealth -= healthIncreasePerLevel;
    maxStamina -= staminaIncreasePerLevel;
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

  CreatureModel copyWith({
    String? name,
    IconData? primaryIcon,
    IconData? secondaryIcon,
    int? level,
    int? maxLevel,
    double? experience,
    double? x,
    double? y,

    double? maxHealth,
    double? health,
    double? healthIncreasePerLevel,

    double? maxStamina,
    double? stamina,
    double? staminaIncreasePerLevel,

    double? damage,
    double? damageIncreasePerLevel,
    double? staminaCostPerAttack,
  });
}
