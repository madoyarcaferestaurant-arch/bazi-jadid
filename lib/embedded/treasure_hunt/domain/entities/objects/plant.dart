import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/core/globals.dart';

class Plant extends GameDecoration {
  Plant({required super.position})
    : super.withSprite(
        sprite: Sprite.load(
          'assets/treasure_hunt/images/plant/${Random().nextInt(18)}.png',
        ),
        size: Vector2.all(Globals.tileSize),
      );
}
