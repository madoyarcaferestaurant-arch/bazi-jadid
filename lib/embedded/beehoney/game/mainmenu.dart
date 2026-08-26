import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'beehoney.dart';
import 'gameover_widget.dart';
import 'util/utils.dart';

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainMenu());
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          gameOver = false;
          score = 0;
          lifes = 3;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameWidget(
                game: BeeHoney(),
                overlayBuilderMap: const {"GameOver": gameOverWidget},
              ),
            ),
          );
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset(
            "assets/beehoney/images/start.png",
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
