import 'package:flame/components.dart';
import 'package:flame/flame.dart';
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
    final image = await Flame.images.load('$name.png');
    final jsonData = await Flame.assets.readJson('images/$name.json');

    final sheetAnimation = SpriteAnimation.fromAsepriteData(image, jsonData);
    final frames = sheetAnimation.frames;

    final frameTags = (jsonData['meta']['frameTags'] as List)
        .cast<Map<String, dynamic>>();

    final loaded = <CreatureState, SpriteAnimation>{};
    for (final tag in frameTags) {
      final state = _getStateFromTag(tag['name'] as String);
      if (state == null) continue;
      loaded[state] = SpriteAnimation(
        frames.sublist(tag['from'] as int, (tag['to'] as int) + 1),
      );
    }

    animations = loaded;
    current = CreatureState.idle;
  }

  CreatureState? _getStateFromTag(String tagName) {
    final normalized = tagName.toLowerCase();
    for (final state in CreatureState.values) {
      if (state.name == normalized) return state;
    }
    return null;
  }

  CreatureState? get state => current;

  set state(CreatureState? state) {
    if (animations != null && state != null && state != current) {
      current = state;
    }
  }
}
