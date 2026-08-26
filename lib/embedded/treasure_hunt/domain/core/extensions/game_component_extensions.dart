import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/core/providers.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/entities/items/coin.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/entities/items/gem.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/entities/items/potion.dart';

extension GameComponentExtensions on GameComponent {
  void playSoundEffect(String soundFile, WidgetRef ref) {
    final volume = ref.read(Providers.audioSettingsProvider).sfxVolume;
    FlameAudio.play(soundFile, volume: volume);
  }

  void dropItem() {
    final pos = Vector2(position.x, position.y - (height / 2));

    final items = [
      CoinDecoration(position: pos),
      GemDecoration(position: pos),
      PotionDecoration(position: pos),
    ];

    final index = Random().nextInt(items.length);

    gameRef.add(items[index]);

    removeFromParent();
  }
}
