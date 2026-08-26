import 'package:flame/components.dart';

class Bg extends SpriteComponent {
  move(dt, speed, limit, posy) {
    y += speed * dt; //Pega posicao eixo y adiciona 1
    if (y >= limit) {
      y = posy;
    }
  }
}
