import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../services/audio_service.dart';

class NeonAsteroidsGameScreen extends StatefulWidget {
  final AppSettings settings;
  const NeonAsteroidsGameScreen({super.key, required this.settings});

  @override
  State<NeonAsteroidsGameScreen> createState() => _NeonAsteroidsGameScreenState();
}

class _NeonAsteroidsGameScreenState extends State<NeonAsteroidsGameScreen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final random = Random();
  final asteroids = <Offset>[];
  int wave = 1;
  int score = 0;
  int best = 0;
  double ship = .5;
  Duration last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadScore();
    _spawnWave();
    _ticker = createTicker(_tick)..start();
    audioService.startMusic();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => best = prefs.getInt('asteroids_best') ?? 0);
  }

  void _spawnWave() {
    asteroids..clear()..addAll(List.generate(4 + wave * 2, (_) => Offset(random.nextDouble(), -random.nextDouble())));
  }

  void _tick(Duration elapsed) {
    if (last == Duration.zero) { last = elapsed; return; }
    final dt = (elapsed - last).inMicroseconds / 1000000;
    last = elapsed;
    for (var i = asteroids.length - 1; i >= 0; i--) {
      final asteroid = asteroids[i];
      final next = Offset(asteroid.dx, asteroid.dy + dt * (.12 + wave * .015));
      if ((next - Offset(ship, .86)).distance < .075) {
        audioService.playEffect(AudioEffect.explosion);
        score = 0;
        wave = 1;
        _spawnWave();
        break;
      }
      if (next.dy > 1.1) {
        asteroids[i] = Offset(random.nextDouble(), -random.nextDouble());
        score++;
        if (score > best) {
          best = score;
          SharedPreferences.getInstance().then((prefs) => prefs.setInt('asteroids_best', best));
        }
        if (score % 10 == 0) { wave++; _spawnWave(); audioService.playEffect(AudioEffect.powerUp); }
      } else {
        asteroids[i] = next;
      }
    }
    if (mounted) setState(() {});
  }

  void _move(DragUpdateDetails details, BoxConstraints constraints) {
    setState(() => ship = (ship + details.delta.dx / constraints.maxWidth).clamp(.08, .92));
    audioService.playEffect(AudioEffect.laser);
  }

  @override
  Widget build(BuildContext context) {
    final fa = widget.settings.isPersian;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xff050014),
        appBar: AppBar(title: Text(fa ? 'سیارک‌های نئونی' : 'Neon Asteroids'), backgroundColor: Colors.transparent),
        body: SafeArea(child: LayoutBuilder(builder: (context, constraints) => GestureDetector(
          onHorizontalDragUpdate: (details) => _move(details, constraints),
          child: Column(children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(fa ? 'موج $wave' : 'WAVE $wave', style: const TextStyle(color: Color(0xff00f5d4), fontWeight: FontWeight.bold)),
              Text(fa ? 'امتیاز $score  رکورد $best' : 'SCORE $score  BEST $best', style: const TextStyle(color: Color(0xffff4ecd), fontWeight: FontWeight.bold)),
            ])),
            Expanded(child: CustomPaint(painter: _AsteroidsPainter(asteroids: asteroids, ship: ship), child: const SizedBox.expand())),
            Padding(padding: const EdgeInsets.all(14), child: Text(fa ? 'برای حرکت، صفحه را بکشید' : 'Drag to steer', style: const TextStyle(color: Colors.white54))),
          ]),
        ))),
      ),
    );
  }
}

class _AsteroidsPainter extends CustomPainter {
  final List<Offset> asteroids;
  final double ship;
  _AsteroidsPainter({required this.asteroids, required this.ship});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..shader = const RadialGradient(colors: [Color(0xff25104b), Color(0xff050014)]).createShader(Offset.zero & size));
    final glow = Paint()..color = const Color(0xffff4ecd)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final core = Paint()..color = const Color(0xffff4ecd);
    for (final asteroid in asteroids) {
      final point = Offset(asteroid.dx * size.width, asteroid.dy * size.height);
      canvas.drawCircle(point, 15, glow);
      canvas.drawCircle(point, 9, core);
    }
    final point = Offset(ship * size.width, size.height * .86);
    final points = [point + const Offset(0, -24), point + const Offset(-17, 18), point + const Offset(0, 10), point + const Offset(17, 18)];
    canvas.drawPath(Path()..addPolygon(points, true), Paint()..color = const Color(0xff00f5d4)..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant _AsteroidsPainter oldDelegate) => true;
}
