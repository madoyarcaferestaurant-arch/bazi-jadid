import 'package:flutter/material.dart';

import 'beehoney.dart';
import 'mainmenu.dart';

Widget gameOverWidget(BuildContext buildContext, BeeHoney game) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        buildContext,
        MaterialPageRoute(builder: (context) => const MainMenu()),
      );
    },
    child: SizedBox(
      width: 500,
      height: 900,
      child: Image.asset(
        "assets/beehoney/images/gameover.png",
        fit: BoxFit.fill,
      ),
    ),
  );
}
