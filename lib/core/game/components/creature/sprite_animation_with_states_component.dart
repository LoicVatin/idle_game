import 'package:flame/components.dart';
import 'package:flame/flame.dart';

enum AnimationState { idle, walk, attack, depleted, rest, defeat }

class SpriteAnimationWithStatesComponent
    extends SpriteAnimationGroupComponent<AnimationState> {
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
      AnimationState.idle: await _loadAnimation('idle'),
      AnimationState.walk: await _loadAnimation('walk'),
      AnimationState.attack: await _loadAnimation('attack'),
      AnimationState.depleted: await _loadAnimation('depleted'),
      AnimationState.rest: await _loadAnimation('rest'),
      AnimationState.defeat: await _loadAnimation('defeat'),
    };
    current = AnimationState.idle;
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
        textureSize: Vector2(32, 32),
      ),
    );
  }

  set state(AnimationState? state) {
    if (animations != null && state != null && state != current) {
      current = state;
    }
  }
}
