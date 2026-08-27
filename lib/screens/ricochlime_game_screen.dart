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
    try {
      await Future.wait([
        LocaleSettings.setLocale(AppLocale.fa),
        stows.highScore.waitUntilRead(),
        stows.stylizedPageTransitions.waitUntilRead(),
        RicochlimeAudio.load(),
        RicochlimeGame.instance.preloadSprites.future,
      ]);
    } catch (error, stackTrace) {
      debugPrint('Ricochlime initialization failed: $error\n$stackTrace');
      rethrow;
    }
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
              return _GameUnavailable(error: snapshot.error!);
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

class _GameUnavailable extends StatelessWidget {
  final Object error;

  const _GameUnavailable({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('خطا در بارگذاری بازی: $error')),
    );
  }
}
