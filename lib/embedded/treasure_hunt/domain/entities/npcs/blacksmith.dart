import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/core/extensions/vector2_extensions.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/core/globals.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/entities/players/dwarf_warrior.dart';
import 'package:madoyar_app/embedded/treasure_hunt/presentation/animations/sprite_animations.dart';

class Blacksmith extends SimpleNpc {
  bool _observedPlayer = false;

  Blacksmith({required super.position})
    : super(
        size: Vector2.all(Globals.tileSize),
        animation: SimpleDirectionAnimation(
          idleRight: SpriteAnimations.blacksmith.idle,
          runRight: SpriteAnimations.blacksmith.idle,
        ),
      );

  @override
  Future<void> onLoad() {
    add(size.actorToHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (gameRef.sceneBuilderStatus.isRunning) return;
    if (gameRef.player != null) {
      seeComponent(
        gameRef.player!,
        observed: (player) {
          _observedPlayer = true;
          (gameRef.player! as DwarfWarrior).blacksmithClose = true;
        },
        notObserved: () {
          _observedPlayer = false;
          (gameRef.player! as DwarfWarrior).blacksmithClose = false;
        },
        radiusVision: Globals.tileSize,
      );
    }

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (_observedPlayer) {
      animation!.showStroke(Colors.white, 2, offset: Vector2(0, -1));
    } else {
      animation!.hideStroke();
    }
    super.render(canvas);
  }
}
