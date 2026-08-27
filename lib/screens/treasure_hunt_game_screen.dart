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
    try {
      FlameAudio.audioCache = AudioCache(prefix: 'assets/treasure_hunt/audio/');
      await FlameAudio.audioCache.loadAll(treasure_main.audios);
      treasure_main.packageInfo = await PackageInfo.fromPlatform();
      treasure_main.logger = Logger();
    } catch (error, stackTrace) {
      debugPrint('Treasure Hunt initialization failed: $error\n$stackTrace');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _GameUnavailable(error: snapshot.error!);
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return ProviderScope(
            child: Consumer(
              builder: (context, ref, child) => MyCoolGame(ref),
            ),
          );
        },
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
