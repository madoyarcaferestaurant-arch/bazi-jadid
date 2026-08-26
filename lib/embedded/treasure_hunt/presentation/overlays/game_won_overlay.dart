import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/core/globals.dart';
import 'package:madoyar_app/embedded/treasure_hunt/presentation/overlays/overlay_container.dart';

class GameWonOverlay extends StatelessWidget {
  final void Function() onReset;

  const GameWonOverlay({required this.onReset, super.key});

  @override
  Widget build(BuildContext context) => OverlayContainer(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(Globals.lottie.gameWon),
        const Gap(32),
        ElevatedButton(
          onPressed: onReset,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Play Again?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ],
    ),
  );
}
