import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/core/extensions/vector2_extensions.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/core/globals.dart';

class WorldObject extends GameDecoration {
  WorldObject({required super.position})
    : super.withSprite(
        sprite: Sprite.load(
          'assets/treasure_hunt/images/world_object/${Random().nextInt(6)}.png',
        ),
        size: Vector2.all(Globals.tileSize),
      );

  @override
  Future<void> onLoad() {
    add(size.objectToHitbox());
    return super.onLoad();
  }
}
