import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Obj extends SpriteComponent with CollisionCallbacks {
  int timer = 0;
  int img = 1;
  String name = "";

  random(min, max) {
    var r = Random();

    return min + r.nextInt(max - min);
  }

  animation(time, spritelimit, name) async {
    timer += 1;
    if (timer > time) {
      timer = 1;
      img += 1;
    }
    if (img > spritelimit) {
      img = 1;
    }
    sprite = await Sprite.load("assets/beehoney/images/$name$img.png");
  }
}
