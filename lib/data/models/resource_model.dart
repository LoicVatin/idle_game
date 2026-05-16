enum ResourceType { food, wood, stone }

class Resource {
  final ResourceType type;
  double amount;
  double encounterInterval;
  double generationRatePerSecond;
  bool encounter;
  double damage;
  double coinMultiplier;
  double movementSpeed;
  double enemyRewardMultiplier;

  Resource({
    required this.type,
    this.amount = 0.0,
    this.encounterInterval = 10,
    this.generationRatePerSecond = 0.0,
    this.encounter = false,
    this.damage = 1,
    this.coinMultiplier = 1,
    this.movementSpeed = 180,
    this.enemyRewardMultiplier = 1
  });

  Resource copyWith({
    ResourceType? type,
    double? amount,
    double? encounterInterval,
    double? generationRatePerSecond,
    bool? encounter
  }) {
    return Resource(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      encounterInterval: encounterInterval ?? this.encounterInterval,
      generationRatePerSecond:
          generationRatePerSecond ?? this.generationRatePerSecond,
        encounter: encounter ?? this.encounter
    );
  }

  void add(double value) => amount += value;

  void subtract(double value) => amount -= value;

  void upgrade(double value) => generationRatePerSecond += value;

  void downgrade(double value) => generationRatePerSecond -= value;

  void reset(bool resetAmount, bool resetGenerationRatePerSecond) {
    amount = resetAmount ? 0.0 : amount;
    generationRatePerSecond = resetGenerationRatePerSecond
        ? 0.0
        : generationRatePerSecond;
  }

  void toggleEncounter(bool encounter) => this.encounter = encounter;
}
