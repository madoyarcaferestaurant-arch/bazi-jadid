import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../models/app_settings.dart';

enum TouchParticleShape {
  sparkCircle,
  sparkStar,
  snowflakeClassic,
  snowflakeCrystal,
  glowOrb,
}

class ActiveParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double initialSize;
  double opacity;
  double life;
  final double decay;
  final double gravity;
  final double drag;
  double rotation;
  final double rotationSpeed;
  double wobblePhase;
  final double wobbleSpeed;
  final double wobbleAmp;
  final TouchParticleShape shape;
  final bool isSnow;

  ActiveParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.initialSize,
    this.opacity = 1.0,
    this.life = 1.0,
    required this.decay,
    required this.gravity,
    required this.drag,
    this.rotation = 0.0,
    required this.rotationSpeed,
    this.wobblePhase = 0.0,
    required this.wobbleSpeed,
    required this.wobbleAmp,
    required this.shape,
    required this.isSnow,
  });

  bool get isDead => life <= 0.0 || opacity <= 0.01;

  void update(double dt) {
    life -= decay * dt;
    if (life < 0) life = 0;
    opacity = life.clamp(0.0, 1.0);

    // Apply physics
    velocity = Offset(velocity.dx * drag, (velocity.dy + gravity) * drag);

    if (isSnow) {
      wobblePhase += wobbleSpeed * dt;
      final wobbleX = math.sin(wobblePhase) * wobbleAmp;
      position += Offset(velocity.dx + wobbleX, velocity.dy);
    } else {
      position += velocity;
    }

    rotation += rotationSpeed * dt;
    size = initialSize * (isSnow ? (0.7 + 0.3 * life) : (0.4 + 0.6 * life));
  }
}

class ExpandWaveRing {
  Offset center;
  double radius;
  double maxRadius;
  Color color;
  double opacity;

  ExpandWaveRing({
    required this.center,
    this.radius = 4.0,
    required this.maxRadius,
    required this.color,
    this.opacity = 0.8,
  });

  bool get isDead => opacity <= 0.02 || radius >= maxRadius;

  void update(double dt) {
    radius += (maxRadius - radius) * 12.0 * dt + 1.2;
    opacity -= 2.2 * dt;
    if (opacity < 0) opacity = 0;
  }
}

class TouchParticleOverlay extends StatefulWidget {
  final Widget child;
  final AppSettings settings;

  const TouchParticleOverlay({
    Key? key,
    required this.child,
    required this.settings,
  }) : super(key: key);

  @override
  State<TouchParticleOverlay> createState() => _TouchParticleOverlayState();
}

class _TouchParticleOverlayState extends State<TouchParticleOverlay>
    with SingleTickerProviderStateMixin {
  final List<ActiveParticle> _particles = [];
  final List<ExpandWaveRing> _rings = [];
  final math.Random _random = math.Random();

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Fireworks Color Palettes
  static const List<List<Color>> _fireworkPalettes = [
    // Golden Luxury
    [Color(0xFFFFD700), Color(0xFFFFB300), Color(0xFFFFF9C4), Color(0xFFFF8F00)],
    // Cyber Neon
    [Color(0xFF00E5FF), Color(0xFFFF007F), Color(0xFF7C4DFF), Color(0xFFFFFFFF)],
    // Aurora Emerald
    [Color(0xFF00E676), Color(0xFF1DE9B6), Color(0xFF69F0AE), Color(0xFFFFFFFF)],
    // Solar Sunset
    [Color(0xFFFF3D00), Color(0xFFFF9100), Color(0xFFFFD600), Color(0xFFFF5252)],
    // Electric Violet
    [Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFF38BDF8), Color(0xFFFFFFFF)],
  ];

  // Snow Palette
  static const List<Color> _snowPalette = [
    Color(0xFFFFFFFF),
    Color(0xFFF0F9FF),
    Color(0xFFE0F2FE),
    Color(0xFFBAE6FD),
    Color(0xFFE0E7FF),
    Color(0xFFFFFBEB),
  ];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    final clampedDt = dt.clamp(0.001, 0.05);

    if (_particles.isEmpty && _rings.isEmpty) {
      _ticker.stop();
      _lastElapsed = Duration.zero;
      return;
    }

    setState(() {
      for (final p in _particles) {
        p.update(clampedDt);
      }
      _particles.removeWhere((p) => p.isDead);

      for (final r in _rings) {
        r.update(clampedDt);
      }
      _rings.removeWhere((r) => r.isDead);
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    widget.settings.playUiFeedback(isHeavy: true);
    if (!widget.settings.touchMeParticles) return;

    final pos = event.localPosition;
    final type = widget.settings.particleType;

    bool spawnFireworks = true;
    if (type == ParticleEffectType.snow) {
      spawnFireworks = false;
    } else if (type == ParticleEffectType.random) {
      spawnFireworks = _random.nextBool();
    }

    if (spawnFireworks) {
      _spawnFireworks(pos);
    } else {
      _spawnSnow(pos);
    }

    if (!_ticker.isActive) {
      _lastElapsed = Duration.zero;
      _ticker.start();
    }
  }

  void _spawnFireworks(Offset center) {
    final palette = _fireworkPalettes[_random.nextInt(_fireworkPalettes.length)];
    final primaryColor = palette.first;

    // Expanding shockwave glow ring
    _rings.add(
      ExpandWaveRing(
        center: center,
        maxRadius: 46.0 + _random.nextDouble() * 24.0,
        color: primaryColor,
      ),
    );

    // Explosive Radial Spark Burst
    final count = 22 + _random.nextInt(12);
    for (int i = 0; i < count; i++) {
      final angle = (_random.nextDouble() * 2 * math.pi);
      final speed = 2.5 + _random.nextDouble() * 7.0;
      final velocity = Offset(math.cos(angle) * speed, math.sin(angle) * speed);
      final color = palette[_random.nextInt(palette.length)];
      final size = 3.5 + _random.nextDouble() * 4.5;
      final shape = (_random.nextDouble() < 0.35)
          ? TouchParticleShape.sparkStar
          : (_random.nextDouble() < 0.25 ? TouchParticleShape.glowOrb : TouchParticleShape.sparkCircle);

      _particles.add(
        ActiveParticle(
          position: center,
          velocity: velocity,
          color: color,
          size: size,
          initialSize: size,
          decay: 0.95 + _random.nextDouble() * 0.7,
          gravity: 0.16 + _random.nextDouble() * 0.12,
          drag: 0.94,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 8.0,
          wobbleSpeed: 0,
          wobbleAmp: 0,
          shape: shape,
          isSnow: false,
        ),
      );
    }
  }

  void _spawnSnow(Offset center) {
    // Light expanding soft icy ring
    _rings.add(
      ExpandWaveRing(
        center: center,
        maxRadius: 36.0 + _random.nextDouble() * 16.0,
        color: const Color(0xFFBAE6FD),
        opacity: 0.5,
      ),
    );

    // Fluttering Snowflake Flurry
    final count = 18 + _random.nextInt(10);
    for (int i = 0; i < count; i++) {
      // Light upward puff that transitions to falling
      final angle = -math.pi * 0.2 - _random.nextDouble() * math.pi * 0.6;
      final speed = 1.2 + _random.nextDouble() * 4.0;
      final velocity = Offset(
        (math.cos(angle) * speed) + (_random.nextDouble() - 0.5) * 1.5,
        math.sin(angle) * speed,
      );

      final color = _snowPalette[_random.nextInt(_snowPalette.length)];
      final size = 5.0 + _random.nextDouble() * 6.0;
      final shape = (_random.nextDouble() < 0.5)
          ? TouchParticleShape.snowflakeClassic
          : (_random.nextDouble() < 0.3 ? TouchParticleShape.snowflakeCrystal : TouchParticleShape.glowOrb);

      _particles.add(
        ActiveParticle(
          position: center + Offset((_random.nextDouble() - 0.5) * 16, (_random.nextDouble() - 0.5) * 16),
          velocity: velocity,
          color: color,
          size: size,
          initialSize: size,
          decay: 0.45 + _random.nextDouble() * 0.35, // Lasts longer than fireworks
          gravity: 0.08 + _random.nextDouble() * 0.08, // Gentle drift downwards
          drag: 0.97,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 3.5,
          wobblePhase: _random.nextDouble() * 2 * math.pi,
          wobbleSpeed: 3.0 + _random.nextDouble() * 4.0,
          wobbleAmp: 1.2 + _random.nextDouble() * 1.8,
          shape: shape,
          isSnow: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (widget.settings.touchMeParticles && (_particles.isNotEmpty || _rings.isNotEmpty))
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ParticleCanvasPainter(
                    particles: _particles,
                    rings: _rings,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ParticleCanvasPainter extends CustomPainter {
  final List<ActiveParticle> particles;
  final List<ExpandWaveRing> rings;

  _ParticleCanvasPainter({
    required this.particles,
    required this.rings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Expanding Glow Waves
    for (final r in rings) {
      final ringPaint = Paint()
        ..color = r.color.withOpacity(r.opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(r.center, r.radius, ringPaint);
    }

    // 2. Draw Particles
    for (final p in particles) {
      final alpha = (p.opacity * 255).clamp(0, 255).toInt();
      if (alpha <= 0) continue;

      final color = p.color.withAlpha(alpha);

      switch (p.shape) {
        case TouchParticleShape.sparkCircle:
          final paint = Paint()
            ..color = color
            ..style = PaintingStyle.fill;
          canvas.drawCircle(p.position, p.size, paint);
          break;

        case TouchParticleShape.glowOrb:
          final glowPaint = Paint()
            ..color = color.withOpacity((p.opacity * 0.45).clamp(0.0, 1.0))
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 1.2);
          canvas.drawCircle(p.position, p.size * 1.5, glowPaint);

          final corePaint = Paint()..color = color;
          canvas.drawCircle(p.position, p.size * 0.7, corePaint);
          break;

        case TouchParticleShape.sparkStar:
          _drawStar(canvas, p.position, p.size * 1.4, color, p.rotation);
          break;

        case TouchParticleShape.snowflakeClassic:
          _drawClassicSnowflake(canvas, p.position, p.size * 1.3, color, p.rotation);
          break;

        case TouchParticleShape.snowflakeCrystal:
          _drawCrystalSnowflake(canvas, p.position, p.size * 1.2, color, p.rotation);
          break;
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color, double angle) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path();
    const points = 4;
    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? radius : radius * 0.32;
      final a = (i / (points * 2)) * 2 * math.pi;
      final x = math.cos(a) * r;
      final y = math.sin(a) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Center white gleam
    final gleamPaint = Paint()..color = Colors.white.withOpacity(color.opacity);
    canvas.drawCircle(Offset.zero, radius * 0.25, gleamPaint);

    canvas.restore();
  }

  void _drawClassicSnowflake(Canvas canvas, Offset center, double radius, Color color, double angle) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // 6-arm symmetry
    for (int i = 0; i < 6; i++) {
      final armAngle = (i / 6) * 2 * math.pi;
      final endX = math.cos(armAngle) * radius;
      final endY = math.sin(armAngle) * radius;
      canvas.drawLine(Offset.zero, Offset(endX, endY), paint);

      // Mini branch crystal needles
      final midX = math.cos(armAngle) * (radius * 0.55);
      final midY = math.sin(armAngle) * (radius * 0.55);
      final branchLen = radius * 0.32;

      final bAngle1 = armAngle + math.pi / 4;
      final bAngle2 = armAngle - math.pi / 4;

      canvas.drawLine(Offset(midX, midY), Offset(midX + math.cos(bAngle1) * branchLen, midY + math.sin(bAngle1) * branchLen), paint);
      canvas.drawLine(Offset(midX, midY), Offset(midX + math.cos(bAngle2) * branchLen, midY + math.sin(bAngle2) * branchLen), paint);
    }

    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(color.opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * 0.2, centerPaint);

    canvas.restore();
  }

  void _drawCrystalSnowflake(Canvas canvas, Offset center, double radius, Color color, double angle) {
    final fillPaint = Paint()
      ..color = color.withOpacity((color.opacity * 0.85).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(color.opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // 6-point diamond crystal polygon
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i / 6) * 2 * math.pi;
      final x = math.cos(a) * radius;
      final y = math.sin(a) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    canvas.drawCircle(Offset.zero, radius * 0.3, Paint()..color = Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ParticleCanvasPainter oldDelegate) => true;
}
