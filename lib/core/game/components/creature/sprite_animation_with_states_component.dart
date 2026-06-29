import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:idle_game/core/game/components/component_utils.dart';
import 'package:idle_game/data/models/creature/creature_state.dart';

class SpriteAnimationWithStatesComponent
    extends SpriteAnimationGroupComponent<CreatureState> {
  final String name;

  SpriteAnimationWithStatesComponent({
    required this.name,
    super.key,
    super.size,
    super.position,
  });

  @override
  Future<void> onLoad() async {
    animations = {
      CreatureState.idle: await _loadAnimation('idle'),
      CreatureState.walk: await _loadAnimation('walk'),
      CreatureState.attack: await _loadAnimation('attack'),
      CreatureState.depleted: await _loadAnimation('depleted'),
      CreatureState.rest: await _loadAnimation('rest'),
      CreatureState.defeat: await _loadAnimation('defeat'),
    };
    current = CreatureState.idle;
  }

  Future<SpriteAnimation> _loadAnimation(
    String state, {
    int frames = 6,
    double stepTime = 0.1,
  }) async {
    return SpriteAnimation.fromFrameData(
      await Flame.images.load('${name}_$state.png'),
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: stepTime,
        textureSize: Vector2.all(Dimensions.regular),
      ),
    );
  }

  CreatureState? get state => current;

  set state(CreatureState? state) {
    if (animations != null && state != null && state != current) {
      current = state;
    }
  }
}
