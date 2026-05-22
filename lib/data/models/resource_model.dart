enum ResourceType { food, wood, stone }

class Resource {
  final ResourceType type;
  double amount;
  double encounterInterval;
  double encounterSpacing;
  double generationRatePerSecond;
  bool encounter;
  double damage;
  double coinMultiplier;
  double movementSpeed;
  double enemyRewardMultiplier;
  double upgradeAmount;
  double upgradeCost;
  double upgradeMultiplier;

  Resource({
    required this.type,
    this.amount = 0.0,
    this.encounterInterval = 25,
    this.encounterSpacing = 100,
    this.generationRatePerSecond = 0.0,
    this.encounter = false,
    this.damage = 1,
    this.coinMultiplier = 1,
    this.movementSpeed = 180,
    this.enemyRewardMultiplier = 1,
    this.upgradeAmount = 0,
    this.upgradeCost = 25,
    this.upgradeMultiplier = 0.5,
  });

  Resource copyWith({
    ResourceType? type,
    double? amount,
    double? encounterInterval,
    double? encounterSpacing,
    double? generationRatePerSecond,
    bool? encounter,
    double? damage,
    double? coinMultiplier,
    double? movementSpeed,
    double? enemyRewardMultiplier,
  }) {
    return Resource(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      encounterInterval: encounterInterval ?? this.encounterInterval,
      encounterSpacing: encounterSpacing ?? this.encounterSpacing,
      generationRatePerSecond:
          generationRatePerSecond ?? this.generationRatePerSecond,
      encounter: encounter ?? this.encounter,
      damage: damage ?? this.damage,
      coinMultiplier: coinMultiplier ?? this.coinMultiplier,
      movementSpeed: movementSpeed ?? this.movementSpeed,
      enemyRewardMultiplier:
          enemyRewardMultiplier ?? this.enemyRewardMultiplier,
    );
  }

  void add(double value) => amount += value;

  void subtract(double value) {
    amount = (amount - value).clamp(0.0, double.infinity);
  }

  void upgrade(double value) => generationRatePerSecond += value;

  void buyUpgrade() {
    amount -= upgradeCost * (upgradeAmount + 1);
    generationRatePerSecond += (upgradeMultiplier * (upgradeAmount + 1));
    upgradeAmount++;
  }

  bool canBuyUpgrade() {
    return amount >= upgradeCost * (upgradeAmount + 1);
  }

  void downgrade(double value) {
    generationRatePerSecond = (generationRatePerSecond - value).clamp(
      0.0,
      double.infinity,
    );
  }

  void reset(bool resetAmount, bool resetGenerationRatePerSecond) {
    amount = resetAmount ? 0.0 : amount;
    generationRatePerSecond = resetGenerationRatePerSecond
        ? 0.0
        : generationRatePerSecond;
  }

  void toggleEncounter(bool encounter) => this.encounter = encounter;
}
