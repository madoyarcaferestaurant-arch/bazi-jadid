import 'package:bonfire/bonfire.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/entities/items/item.dart';
import 'package:madoyar_app/embedded/treasure_hunt/presentation/animations/sprite_animations.dart';

class Potion extends Item {
  Potion() : super(id: 'potion', name: 'Potion', spritePath: 'item/potion.png');
}

class PotionDecoration extends ItemDecoration {
  PotionDecoration({required super.position})
    : super.withAnimation(
        size: Vector2.all(16),
        animation: SpriteAnimations.inventory.potion,
      );
}
