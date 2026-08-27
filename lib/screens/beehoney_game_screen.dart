import 'package:flame/game.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../embedded/beehoney/game/beehoney.dart';
import '../embedded/beehoney/game/gameover_widget.dart';
import '../embedded/beehoney/game/util/utils.dart';
import '../models/app_settings.dart';

class BeeHoneyGameScreen extends StatefulWidget {
  final AppSettings settings;

  const BeeHoneyGameScreen({super.key, required this.settings});

  @override
  State<BeeHoneyGameScreen> createState() => _BeeHoneyGameScreenState();
}

class _BeeHoneyGameScreenState extends State<BeeHoneyGameScreen> {
  final _music = AudioPlayer(playerId: 'beehoney-music');
  final _effects = AudioPlayer(playerId: 'beehoney-effects');

  @override
  void initState() {
    super.initState();
    gameOver = false;
    score = 0;
    lifes = 3;
    _startMusic();
  }

  Future<void> _startMusic() async {
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(0.18);
      await _music.play(AssetSource('beehoney/audio/theme.wav'));
    } catch (error, stackTrace) {
      debugPrint('Beehoney audio initialization failed: $error\n$stackTrace');
    }
  }

  Future<void> _playCollectEffect() async {
    await _effects.play(
      AssetSource('beehoney/audio/collect.wav'),
      volume: 0.65,
    );
  }

  @override
  void dispose() {
    _music.dispose();
    _effects.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget.controlled(
        gameFactory: () => BeeHoney(onFlowerCollected: _playCollectEffect),
        overlayBuilderMap: const {'GameOver': gameOverWidget},
        errorBuilder: (context, error) => _GameUnavailable(error: error),
      ),
    );
  }
}

class _GameUnavailable extends StatelessWidget {
  final Object error;

  const _GameUnavailable({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('خطا در بارگذاری بازی: $error'));
  }
}
