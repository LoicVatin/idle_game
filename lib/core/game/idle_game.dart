import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/bottom_panel_component.dart';
import 'package:idle_game/core/game/components/component_utils.dart';
import 'package:idle_game/core/game/components/playground_component.dart';
import 'package:idle_game/core/game/components/resource_panel_component.dart';
import 'package:idle_game/core/game/components/scrollable_component_list.dart';
import 'package:idle_game/presentation/core/game_provider.dart';
import 'package:idle_game/utils/logger_helper.dart';
import 'package:idle_game/core/styles/app_colors.dart';

class IdleGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final GameStateNotifier gameStateNotifier;
  final TextTheme textTheme;

  IdleGame({required this.gameStateNotifier, required this.textTheme});

  late final ResourcePanelComponent resourcePanelComponent;
  late final ScrollableComponentList _playgroundList;
  late final BottomPanelComponent bottomPanelComponent;

  static const String upgradeOverlay = 'upgrade_overlay';
  static const String tutorialOverlay = 'tutorial_overlay';
  int? upgradeOverlayPlaygroundId;

  PlaygroundComponent? get firstPlaygroundComponent => children
      .whereType<ScrollableComponentList>()
      .firstOrNull
      ?.children
      .whereType<PlaygroundComponent>()
      .firstOrNull;

  @override
  Color backgroundColor() => AppColors.lightDark;

  @override
  Future<void> onLoad() async {
    appLogger.d("IdleGame.onLoad()");
    resourcePanelComponent = ResourcePanelComponent(
      position: Vector2.zero(),
      size: Vector2(
        size.x,
        Dimensions.medium +
            Dimensions.extraSmall +
            Dimensions.extraSmall +
            Dimensions.small +
            Dimensions.small,
      ),
    );
    add(resourcePanelComponent);

    _playgroundList = ScrollableComponentList(
      position: Vector2(0, Dimensions.large),
      size: Vector2(size.x, size.y - Dimensions.huge),
    );

    await add(_playgroundList);

    await _playgroundList.setItems([
      ...gameStateNotifier.currentData.playgrounds.map((playground) {
        return PlaygroundComponent(playground: playground);
      }),
    ]);

    bottomPanelComponent = BottomPanelComponent(
      anchor: Anchor.bottomRight,
      position: Vector2(size.x, size.y),
      size: Vector2(
        size.x,
        Dimensions.medium +
            Dimensions.extraSmall +
            Dimensions.extraSmall +
            Dimensions.small +
            Dimensions.small,
      ),
      onPressed: addPlayground,
    );
    add(bottomPanelComponent);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameStateNotifier.updatePlaygrounds(dt);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (isLoaded) {
      resourcePanelComponent
        ..position.setZero()
        ..size.setValues(
          size.x,
          Dimensions.medium +
              Dimensions.extraSmall +
              Dimensions.extraSmall +
              Dimensions.small +
              Dimensions.small,
        );
      _playgroundList
        ..position.setValues(
          0,
          Dimensions.medium +
              Dimensions.extraSmall +
              Dimensions.extraSmall +
              Dimensions.small +
              Dimensions.small,
        )
        ..size.setValues(
          size.x,
          size.y -
              (Dimensions.medium +
                      Dimensions.extraSmall +
                      Dimensions.extraSmall +
                      Dimensions.small +
                      Dimensions.small) *
                  2,
        );
      bottomPanelComponent
        ..position.setValues(size.x, size.y)
        ..size.setValues(
          size.x,
          Dimensions.medium +
              Dimensions.extraSmall +
              Dimensions.extraSmall +
              Dimensions.small +
              Dimensions.small,
        );
    }
  }

  void displayUpgradeOverlay(int id) {
    upgradeOverlayPlaygroundId = id;
    overlays.add(IdleGame.upgradeOverlay);
  }

  void dismissUpgradeOverlay() {
    upgradeOverlayPlaygroundId = null;
    overlays.remove(IdleGame.upgradeOverlay);
  }

  void displayTutorialOverlay() {
    overlays.add(IdleGame.tutorialOverlay);
  }

  void dismissTutorialOverlay() {
    overlays.remove(IdleGame.tutorialOverlay);
  }

  Future<void> addPlayground() async {
    final playground = gameStateNotifier.addPlayground();

    await _playgroundList.addItem(PlaygroundComponent(playground: playground));
  }
}
