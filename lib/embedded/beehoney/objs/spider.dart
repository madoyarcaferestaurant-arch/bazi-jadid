import 'package:flame/components.dart';

import 'obj.dart';

class Spider extends Obj {
  move(dt, bee) {
    y += 100 * dt;
    if (y > 950) {
      y = -50;
    }

    if (x < bee.x) {
      x += 2;
    } else if (x > bee.x) {
      x -= 2;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Spider) {
      other.position.y = -100.0;
    }
  }
}
