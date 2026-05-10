import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/resource_model.dart';

final gameStateProvider =
    AsyncNotifierProvider<GameStateNotifier, GameStateData>(
      GameStateNotifier.new,
    );

@immutable
class GameStateData {
  final Resource wood;

  const GameStateData({required this.wood});

  factory GameStateData.initial() {
    return GameStateData(wood: Resource(type: ResourceType.wood));
  }

  GameStateData copyWith({Resource? wood}) {
    return GameStateData(wood: wood ?? this.wood);
  }
}

class GameStateNotifier extends AsyncNotifier<GameStateData> {
  GameStateData get currentData => state.value ?? GameStateData.initial();

  @override
  FutureOr<GameStateData> build() {
    return GameStateData.initial();
  }

  void _setData(GameStateData data) {
    state = AsyncData(data);
  }

  void add(double amount) {
    print("add ($amount)");
    if (amount <= 0) return;

    final data = currentData;
    final resource = currentData.wood.copyWith();
    resource.add(amount);
    _setData(data.copyWith(wood: resource));
  }

  void subtract(double amount) {
    print("subtract ($amount)");
    if (amount <= 0) return;

    final data = currentData;
    final resource = currentData.wood.copyWith();
    resource.subtract(amount);
    _setData(data.copyWith(wood: resource));
  }

  void upgradeResource(double amount) {
    print("upgradeResource ($amount)");
    if (amount <= 0) return;

    final data = currentData;
    final resource = currentData.wood.copyWith();
    resource.upgrade(amount);
    _setData(data.copyWith(wood: resource));
  }

  void downgradeResource(double amount) {
    print("downgradeResource ($amount)");
    if (amount <= 0) return;

    final data = currentData;
    final resource = currentData.wood.copyWith();
    resource.downgrade(amount);
    _setData(data.copyWith(wood: resource));
  }

  void updateResource(double dt) {
    if (dt <= 0) return;

    final data = currentData;
    final resource = currentData.wood.copyWith();

    final generatedAmount = resource.generationRatePerSecond * dt;

    resource.add(generatedAmount.toDouble());

    _setData(data.copyWith(wood: resource));
  }
}
