import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../embedded/treasure_hunt/main.dart' as treasure_main;
import '../embedded/treasure_hunt/presentation/my_cool_game.dart';
import '../models/app_settings.dart';

class TreasureHuntGameScreen extends StatefulWidget {
  final AppSettings settings;

  const TreasureHuntGameScreen({super.key, required this.settings});

  @override
  State<TreasureHuntGameScreen> createState() => _TreasureHuntGameScreenState();
}

class _TreasureHuntGameScreenState extends State<TreasureHuntGameScreen> {
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    FlameAudio.audioCache = AudioCache(prefix: 'assets/treasure_hunt/audio/');
    treasure_main.packageInfo = await PackageInfo.fromPlatform();
    treasure_main.logger = Logger();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('خطا در بارگذاری بازی: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return ProviderScope(
            child: Consumer(builder: (context, ref, child) => MyCoolGame(ref)),
          );
        },
      ),
    );
  }
}
