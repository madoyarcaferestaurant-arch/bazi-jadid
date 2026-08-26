import 'package:flutter/material.dart';
import 'package:ricochlime/i18n/strings.g.dart';
import 'package:ricochlime/flame/ricochlime_game.dart';
import 'package:ricochlime/pages/play.dart';
import 'package:ricochlime/utils/ricochlime_audio.dart';
import 'package:ricochlime/utils/stows.dart';
import '../models/app_settings.dart';

class RicochlimeGameScreen extends StatefulWidget {
  final AppSettings settings;

  const RicochlimeGameScreen({super.key, required this.settings});

  @override
  State<RicochlimeGameScreen> createState() => _RicochlimeGameScreenState();
}

class _RicochlimeGameScreenState extends State<RicochlimeGameScreen> {
  late final Future<void> _preparation;

  @override
  void initState() {
    super.initState();
    _preparation = _prepareGame();
  }

  Future<void> _prepareGame() async {
    await Future.wait([
      LocaleSettings.setLocale(AppLocale.fa),
      stows.highScore.waitUntilRead(),
      stows.stylizedPageTransitions.waitUntilRead(),
      RicochlimeAudio.load(),
      RicochlimeGame.instance.preloadSprites.future,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TranslationProvider(
        child: FutureBuilder<void>(
          future: _preparation,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('خطا در بارگذاری بازی: ${snapshot.error}'));
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return const PlayPage();
          },
        ),
      ),
    );
  }
}
