import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../objs/bee.dart';
import '../objs/bg.dart';
import '../objs/flower.dart';
import '../objs/spider.dart';
import '../objs/text.dart';
import 'util/utils.dart';

class BeeHoney extends FlameGame with HasCollisionDetection, KeyboardEvents {
  BeeHoney({this.onFlowerCollected});

  final VoidCallback? onFlowerCollected;

  // SpriteComponent -> Definir Posição Cor tipo imagem tamanho
  Bg bg = Bg();
  Bg bg2 = Bg();
  late final Bee bee = Bee(onFlowerCollected: onFlowerCollected);
  Spider spider = Spider();
  Flower flower = Flower();

  GameText textScore = GameText(
    'Score: $score',
    10,
    10,
    BasicPalette.black.color,
    20,
  );
  GameText textLifes = GameText(
    'Lifes: $score',
    400,
    10,
    BasicPalette.black.color,
    20,
  );

  @override
  Future<void>? onLoad() async {
    bg
      ..sprite = await Sprite.load("assets/beehoney/images/bg.png")
      ..size.x =
          500 // tamanho em X
      ..size.y =
          900 //tamanho em Y
      ..position = Vector2(0, 0); // Posicao em X | Y

    bg2
      ..sprite = await Sprite.load("assets/beehoney/images/bg.png")
      ..size.x =
          500 // tamanho em X
      ..size.y =
          900 //tamanho em Y
      ..position = Vector2(0, -900)
      ..add(RectangleHitbox());

    bee
      ..sprite = await Sprite.load("assets/beehoney/images/bee1.png")
      ..size =
          Vector2.all(50) //---> Define tamanho
      ..position = Vector2(250, 800)
      ..anchor = Anchor
          .center // Define ela no ponto central
      ..add(RectangleHitbox());

    spider
      ..sprite = await Sprite.load("assets/beehoney/images/spider1.png")
      ..size = Vector2.all(80)
      ..position = Vector2(250, 500)
      ..anchor = Anchor.center
      ..add(RectangleHitbox());

    flower
      ..sprite = await Sprite.load("assets/beehoney/images/florwer1.png")
      ..size = Vector2.all(30)
      ..position = Vector2(200, 400)
      ..anchor = Anchor.center
      ..add(RectangleHitbox());

    // Adicione o objeto na tela
    add(bg);
    add(bg2);
    add(bee);
    add(spider);
    add(flower);
    add(textScore);
    add(textLifes);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    //delta time- independente do nivel de processamento
    bg.move(dt, 100, 900, 0.0);
    bg2.move(dt, 100, 0, -900.0);

    bee.move(dt, 10);
    bee.animation(8, 4, 'bee');

    spider.animation(8, 4, 'spider');
    spider.move(dt, bee);

    flower.move(dt, 110);
    flower.animation(8, 2, 'florwer');

    textScore.text = textPts + score.toString();
    textLifes.text = lifesTxt + lifes.toString();

    if (gameOver) {
      pauseEngine();
      overlays.add('GameOver');
      //resumeEngine();
    }

    super.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      bee.left = true;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      bee.right = true;
    } else {
      bee.left = false;
      bee.right = false;
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
