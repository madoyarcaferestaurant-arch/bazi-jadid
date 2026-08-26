import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'models/app_settings.dart';
import 'theme/app_themes.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/about_us_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/two_sparks_game_screen.dart';
import 'screens/hokm_game_screen.dart';
import 'screens/gems_game_screen.dart';
import 'screens/ricochlime_game_screen.dart';
import 'screens/neon_asteroids_game_screen.dart';
import 'screens/maplestory_game_screen.dart';
import 'screens/beehoney_game_screen.dart';
import 'screens/treasure_hunt_game_screen.dart';
import 'widgets/touch_particle_overlay.dart';
import 'services/audio_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MadoyarApp());
}

class MadoyarApp extends StatefulWidget {
  const MadoyarApp({Key? key}) : super(key: key);

  @override
  State<MadoyarApp> createState() => _MadoyarAppState();
}

class _MadoyarAppState extends State<MadoyarApp> {
  late final AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = AppSettings();
    audioService.startMusic();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settings,
      builder: (context, child) {
        return MaterialApp(
          title: 'مادویار',
          debugShowCheckedModeBanner: false,
          locale: const Locale('fa', 'IR'),
          supportedLocales: const [Locale('fa', 'IR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => Directionality(
            textDirection: _settings.isPersian
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
          theme: AppThemes.getTheme(_settings.themeType),
          initialRoute: '/',
          routes: {
            '/': (context) => TouchParticleOverlay(
              settings: _settings,
              child: SplashScreen(settings: _settings),
            ),
            '/home': (context) => TouchParticleOverlay(
              settings: _settings,
              child: HomeScreen(settings: _settings),
            ),
            '/about': (context) => TouchParticleOverlay(
              settings: _settings,
              child: AboutUsScreen(settings: _settings),
            ),
            '/settings': (context) => TouchParticleOverlay(
              settings: _settings,
              child: SettingsScreen(settings: _settings),
            ),
            '/two_sparks': (context) =>
                TwoSparksGameScreen(settings: _settings),
            '/hokm': (context) => HokmGameScreen(settings: _settings),
            '/gems': (context) => GemsGameScreen(settings: _settings),
            '/neon_asteroids': (context) =>
                NeonAsteroidsGameScreen(settings: _settings),
            '/ricochlime': (context) =>
                RicochlimeGameScreen(settings: _settings),
            '/maplestory': (context) =>
                MapleStoryGameScreen(settings: _settings),
            '/beehoney': (context) => BeeHoneyGameScreen(settings: _settings),
            '/treasure_hunt': (context) =>
                TreasureHuntGameScreen(settings: _settings),
          },
        );
      },
    );
  }
}
