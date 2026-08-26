import 'package:flame/game.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../embedded/maplestory/maple_story.dart';
import '../models/app_settings.dart';

class MapleStoryGameScreen extends StatefulWidget {
  final AppSettings settings;

  const MapleStoryGameScreen({super.key, required this.settings});

  @override
  State<MapleStoryGameScreen> createState() => _MapleStoryGameScreenState();
}

class _MapleStoryGameScreenState extends State<MapleStoryGameScreen> {
  final _music = AudioPlayer(playerId: 'maplestory-music');

  @override
  void initState() {
    super.initState();
    _startMusic();
  }

  Future<void> _startMusic() async {
    await _music.setReleaseMode(ReleaseMode.loop);
    await _music.setVolume(0.18);
    await _music.play(AssetSource('maplestory/audio/theme.wav'));
  }

  @override
  void dispose() {
    _music.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GameWidget(game: MapleStory()));
  }
}
