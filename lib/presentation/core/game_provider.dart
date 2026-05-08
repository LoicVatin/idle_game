import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameStateProvider =
    AsyncNotifierProvider<GameStateNotifier, GameStateData>(
      GameStateNotifier.new,
    );

@immutable
class GameStateData {
  final int counter;

  const GameStateData({required this.counter});

  factory GameStateData.initial() {
    return GameStateData(counter: 0);
  }

  GameStateData copyWith({int? counter}) {
    return GameStateData(counter: counter ?? this.counter);
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

  void incrementCounter() {
    final data = currentData;

    _setData(data.copyWith(counter: data.counter + 1));
  }
}
