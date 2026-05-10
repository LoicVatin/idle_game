enum ResourceType { food, wood, stone }

class Resource {
  final ResourceType type;
  double amount;
  double generationRatePerSecond;

  Resource({
    required this.type,
    this.amount = 0.0,
    this.generationRatePerSecond = 0.0,
  });

  Resource copyWith({
    ResourceType? type,
    double? amount,
    double? generationRatePerSecond,
  }) {
    return Resource(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      generationRatePerSecond:
          generationRatePerSecond ?? this.generationRatePerSecond,
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
}
