import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_game/presentation/core/game_provider.dart';

import '../../generated/intl/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return gameState.when(
      data: (data) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(AppLocalizations.of(context)!.app_name),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Text(AppLocalizations.of(context)!.app_name),
                const Text('You have pushed the button this many times:'),
                Text(
                  "${ref.read(gameStateProvider).value?.counter}",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                ref.read(gameStateProvider.notifier).incrementCounter(),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        );
      },
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Failed to load game'))),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
