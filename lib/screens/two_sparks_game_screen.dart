import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_settings.dart';

enum GateType {
  splitOuter, // Barrier in center -> orbs must be in WIDE safe zone
  narrowCenter, // Barriers on sides -> orbs must be in NARROW safe zone
  beatPulseRing, // Music beat ring -> tap right on beat
  energyCrystal, // Bonus energy node
}

class ObstacleGate {
  double y; // 0.0 (top spawn) to 1.15 (bottom offscreen)
  final GateType type;
  final double beatTargetY;
  bool resolved = false;
  bool passedSuccessfully = false;
  String hitQuality = ''; // 'PERFECT', 'GOOD', 'MISS'

  ObstacleGate({
    required this.y,
    required this.type,
    this.beatTargetY = 0.75,
  });
}

class FloatingScoreText {
  final String text;
  final Offset position;
  final Color color;
  double opacity = 1.0;
  double yOffset = 0.0;

  FloatingScoreText({
    required this.text,
    required this.position,
    required this.color,
  });

  bool get isDead => opacity <= 0.05;

  void update() {
    yOffset -= 1.8;
    opacity -= 0.035;
  }
}

class SparkParticleEffect {
  Offset position;
  Offset velocity;
  Color color;
  double radius;
  double opacity = 1.0;

  SparkParticleEffect({
    required this.position,
    required this.velocity,
    required this.color,
    required this.radius,
  });

  bool get isDead => opacity <= 0.05;

  void update() {
    position += velocity;
    velocity *= 0.92;
    opacity -= 0.038;
    if (radius > 0.4) radius -= 0.05;
  }
}

class TwoSparksGameScreen extends StatefulWidget {
  final AppSettings settings;

  const TwoSparksGameScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<TwoSparksGameScreen> createState() => _TwoSparksGameScreenState();
}

class _TwoSparksGameScreenState extends State<TwoSparksGameScreen>
    with TickerProviderStateMixin {
  // Game Loop Animation (60 FPS)
  late AnimationController _gameLoopController;

  // Orb alignment animation: 0.0 = Narrow (Close), 1.0 = Wide (Apart)
  late AnimationController _orbAlignController;
  late Animation<double> _orbAlignAnimation;
  bool _isWide = true;

  // Beat Pulse animation for music rhythm
  late AnimationController _beatPulseController;
  late Animation<double> _beatPulseAnimation;

  // Round Configuration (25 Seconds)
  static const double kRoundDurationSec = 25.0;
  double _timeRemaining = kRoundDurationSec;
  bool _isPlaying = false;
  bool _isGameOver = false;

  // Scoring as specified:
  // Perfect tap = +3 points
  // Good tap = +2 points
  // Miss = 0 points (and mistakes reduce score without ending game)
  // Combo multiplier every 5 perfect taps (1-4 = x1, 5-9 = x2, 10-14 = x3, etc.)
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _perfectHits = 0;
  int _goodHits = 0;
  int _missHits = 0;

  // Neon theme colors
  final Color _primaryNeon = const Color(0xFF00E5FF); // Cyan Glow
  final Color _secondaryNeon = const Color(0xFFFF007F); // Magenta Glow

  // Game entities
  final List<ObstacleGate> _gates = [];
  final List<SparkParticleEffect> _particles = [];
  final List<FloatingScoreText> _floatingTexts = [];

  double _spawnTimer = 0.0;
  double _bpmSpeed = 1.0;
  double _bgWarpPhase = 0.0;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_gameTick);

    _orbAlignController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _orbAlignAnimation = CurvedAnimation(
      parent: _orbAlignController,
      curve: Curves.easeOutBack,
    );
    _orbAlignController.value = 1.0; // Start in Wide mode

    _beatPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _beatPulseAnimation = CurvedAnimation(
      parent: _beatPulseController,
      curve: Curves.easeInOut,
    );

    _startNewRound();
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    _orbAlignController.dispose();
    _beatPulseController.dispose();
    super.dispose();
  }

  void _startNewRound() {
    setState(() {
      _score = 0;
      _combo = 0;
      _maxCombo = 0;
      _perfectHits = 0;
      _goodHits = 0;
      _missHits = 0;
      _timeRemaining = kRoundDurationSec;
      _isPlaying = true;
      _isGameOver = false;
      _isWide = true;
      _orbAlignController.value = 1.0;
      _gates.clear();
      _particles.clear();
      _floatingTexts.clear();
      _spawnTimer = 0.0;
      _bpmSpeed = 1.0;
    });
    _gameLoopController.repeat();
  }

  int get _comboMultiplier {
    // Multiplier increases every 5 perfect taps:
    // 0-4 = x1, 5-9 = x2, 10-14 = x3, 15-19 = x4, etc.
    return (_perfectHits ~/ 5) + 1;
  }

  void _onPlayerTap() {
    if (!_isPlaying || _isGameOver) {
      _startNewRound();
      return;
    }

    // Toggle alignment between Wide & Narrow
    _isWide = !_isWide;
    if (_isWide) {
      _orbAlignController.forward();
    } else {
      _orbAlignController.reverse();
    }

    if (widget.settings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    widget.settings.playUiFeedback();

    // Trigger visual particle ripple
    _triggerTapBurst();

    // Check if player tapped on an approaching obstacle within hit window
    _checkTapAccuracy();
  }

  void _triggerTapBurst() {
    final colors = [_primaryNeon, _secondaryNeon, Colors.white];
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width * 0.5, size.height * 0.75);

    for (int i = 0; i < 10; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 3.0 + _random.nextDouble() * 5.0;
      _particles.add(
        SparkParticleEffect(
          position: center,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: colors[_random.nextInt(colors.length)],
          radius: 3.0 + _random.nextDouble() * 3.0,
        ),
      );
    }
  }

  void _checkTapAccuracy() {
    const targetY = 0.75;
    const hitTolerance = 0.09;

    ObstacleGate? closestGate;
    double minDistance = 999.0;

    for (var gate in _gates) {
      if (!gate.resolved) {
        final dist = (gate.y - targetY).abs();
        if (dist < hitTolerance && dist < minDistance) {
          minDistance = dist;
          closestGate = gate;
        }
      }
    }

    if (closestGate != null) {
      _resolveGate(closestGate, minDistance);
    }
  }

  void _resolveGate(ObstacleGate gate, double distance) {
    if (gate.resolved) return;
    gate.resolved = true;

    final size = MediaQuery.of(context).size;
    final gatePos = Offset(size.width * 0.5, size.height * 0.75);

    bool isAligned = false;
    switch (gate.type) {
      case GateType.splitOuter:
        isAligned = _isWide; // Wide safe zone
        break;
      case GateType.narrowCenter:
        isAligned = !_isWide; // Narrow safe zone
        break;
      case GateType.beatPulseRing:
      case GateType.energyCrystal:
        isAligned = true;
        break;
    }

    if (isAligned) {
      // Perfect tap <= 0.04 distance, Good tap <= 0.09
      final isPerfect = distance <= 0.045;
      final mult = _comboMultiplier;

      if (isPerfect) {
        // Perfect tap = +3 points (multiplied by combo multiplier)
        final earned = 3 * mult;
        _score += earned;
        _perfectHits++;
        _combo++;
        if (_combo > _maxCombo) _maxCombo = _combo;
        gate.passedSuccessfully = true;
        gate.hitQuality = 'PERFECT';

        _floatingTexts.add(
          FloatingScoreText(
            text: 'PERFECT +$earned${mult > 1 ? " (x$mult)" : ""}',
            position: gatePos,
            color: _primaryNeon,
          ),
        );

        // Success burst
        _spawnSuccessSparks(gatePos, _primaryNeon);
      } else {
        // Good tap = +2 points (multiplied by combo multiplier)
        final earned = 2 * mult;
        _score += earned;
        _goodHits++;
        _combo++;
        if (_combo > _maxCombo) _maxCombo = _combo;
        gate.passedSuccessfully = true;
        gate.hitQuality = 'GOOD';

        _floatingTexts.add(
          FloatingScoreText(
            text: 'GOOD +$earned',
            position: gatePos,
            color: _secondaryNeon,
          ),
        );

        _spawnSuccessSparks(gatePos, _secondaryNeon);
      }
    } else {
      // Misaligned: Miss = 0 points, mistake reduces score by 2, does NOT end game
      _triggerMiss(gate, gatePos, 'MISALIGNED');
    }
  }

  void _triggerMiss(ObstacleGate gate, Offset pos, String reason) {
    gate.resolved = true;
    gate.passedSuccessfully = false;
    gate.hitQuality = 'MISS';
    _missHits++;
    _combo = 0;
    // Mistakes reduce score but do NOT end game
    _score = math.max(0, _score - 2);

    widget.settings.playUiFeedback(isHeavy: true);

    _floatingTexts.add(
      FloatingScoreText(
        text: 'MISS 0 (-2)',
        position: pos,
        color: Colors.redAccent,
      ),
    );

    // Red deflection sparks
    for (int i = 0; i < 10; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final spd = 4.0 + _random.nextDouble() * 5.0;
      _particles.add(
        SparkParticleEffect(
          position: pos,
          velocity: Offset(math.cos(angle) * spd, math.sin(angle) * spd),
          color: Colors.redAccent,
          radius: 3.5,
        ),
      );
    }
  }

  void _spawnSuccessSparks(Offset pos, Color color) {
    for (int i = 0; i < 8; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final spd = 3.5 + _random.nextDouble() * 4.5;
      _particles.add(
        SparkParticleEffect(
          position: pos,
          velocity: Offset(math.cos(angle) * spd, math.sin(angle) * spd),
          color: color,
          radius: 3.5,
        ),
      );
    }
  }

  void _gameTick() {
    if (!_isPlaying || _isGameOver) return;

    final dt = 0.016; // ~60 FPS step
    setState(() {
      _timeRemaining -= dt;
      _bgWarpPhase += 0.04 * _bpmSpeed;

      // Speed intensifies slightly over the 25 seconds
      _bpmSpeed = 1.0 + (kRoundDurationSec - _timeRemaining) / 45.0;

      if (_timeRemaining <= 0) {
        _timeRemaining = 0;
        _endGame();
        return;
      }

      // Spawn obstacle gates at timed beat intervals
      _spawnTimer += dt * _bpmSpeed;
      if (_spawnTimer >= 0.85) {
        _spawnTimer = 0.0;
        _spawnRandomGate();
      }

      // Move gates downward (towards player hit line at y=0.75)
      final gateSpeed = (0.42 * _bpmSpeed) * dt;
      for (var gate in _gates) {
        gate.y += gateSpeed;
      }

      // Check auto-resolution for gates passing the hit line without tap
      const targetY = 0.75;
      final size = MediaQuery.of(context).size;
      for (var gate in _gates) {
        if (!gate.resolved && gate.y >= targetY) {
          // If gate reached target line, evaluate based on current alignment
          final dist = (gate.y - targetY).abs();
          _resolveGate(gate, dist);
        }
      }

      // Remove off-screen gates
      _gates.removeWhere((g) => g.y > 1.15);

      // Update particles
      _particles.removeWhere((p) => p.isDead);
      for (var p in _particles) {
        p.update();
      }

      // Update floating texts
      _floatingTexts.removeWhere((t) => t.isDead);
      for (var t in _floatingTexts) {
        t.update();
      }
    });
  }

  void _spawnRandomGate() {
    final types = [
      GateType.splitOuter,
      GateType.narrowCenter,
      GateType.splitOuter,
      GateType.narrowCenter,
      GateType.beatPulseRing,
      GateType.energyCrystal,
    ];
    final type = types[_random.nextInt(types.length)];
    _gates.add(ObstacleGate(y: -0.1, type: type));
  }

  void _endGame() {
    _isPlaying = false;
    _isGameOver = true;
    _gameLoopController.stop();

    widget.settings.playUiFeedback(isHeavy: true);
  }

  String _calculateRank() {
    if (_score >= 70) return 'S+';
    if (_score >= 50) return 'S';
    if (_score >= 35) return 'A';
    if (_score >= 20) return 'B';
    return 'C';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isFa = widget.settings.isRtl;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: GestureDetector(
        onTapDown: (_) => _onPlayerTap(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // 1. CustomPainter for Dark Neon Horizon, Tracks, Twin Glowing Sparks, Obstacles & Trails
            CustomPaint(
              size: size,
              painter: _TwoSparksPainter(
                alignProgress: _orbAlignAnimation.value,
                beatProgress: _beatPulseAnimation.value,
                bgWarpPhase: _bgWarpPhase,
                gates: _gates,
                particles: _particles,
                glowColor1: _primaryNeon,
                glowColor2: _secondaryNeon,
                combo: _combo,
              ),
            ),

            // 2. Floating floating score texts
            ..._floatingTexts.map((f) {
              return Positioned(
                left: f.position.dx - 90,
                top: f.position.dy + f.yOffset,
                child: Opacity(
                  opacity: f.opacity.clamp(0.0, 1.0),
                  child: Container(
                    width: 180,
                    alignment: Alignment.center,
                    child: Text(
                      f.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: f.color,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        shadows: [
                          Shadow(color: f.color.withOpacity(0.8), blurRadius: 14),
                          const Shadow(color: Colors.black, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),

            // 3. HUD Header & Progress Bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Top Bar: Back button, Score, Multiplier, Restart
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),

                        // Score Badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFa ? 'امتیاز' : 'SCORE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.6),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              Text(
                                '$_score',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: _primaryNeon,
                                  shadows: [
                                    Shadow(color: _primaryNeon.withOpacity(0.7), blurRadius: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Combo & Multiplier Badges
                        if (_comboMultiplier > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.amberAccent),
                            ),
                            child: Text(
                              '${_comboMultiplier}x MULTI',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),

                        if (_combo > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_secondaryNeon, _primaryNeon],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _secondaryNeon.withOpacity(0.5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Text(
                              '${_combo}x COMBO',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),

                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                          onPressed: _startNewRound,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Round Time Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          FractionallySizedBox(
                            widthFactor: (_timeRemaining / kRoundDurationSec).clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _timeRemaining < 6 ? Colors.redAccent : _primaryNeon,
                                    _secondaryNeon,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isFa ? 'زمان راند (۲۵ ثانیه)' : 'ROUND TIME (25s)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '${_timeRemaining.toStringAsFixed(1)}s',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _timeRemaining < 6 ? Colors.redAccent : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 4. Safe Zone Mode Indicator & Tap Tip at Bottom
            if (_isPlaying && !_isGameOver)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isWide ? _primaryNeon.withOpacity(0.6) : _secondaryNeon.withOpacity(0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 16,
                          color: _isWide ? _primaryNeon : _secondaryNeon,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isWide
                              ? (isFa ? 'حالت عریض: ضربه برای باریک' : 'WIDE MODE: TAP TO NARROW')
                              : (isFa ? 'حالت باریک: ضربه برای عریض' : 'NARROW MODE: TAP TO WIDE'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 5. Game Over / Round Summary Dialog
            if (_isGameOver)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.88),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Rank Banner
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [_primaryNeon, _secondaryNeon],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryNeon.withOpacity(0.6),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _calculateRank(),
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            isFa ? 'پایان راند' : 'ROUND COMPLETE',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Stats Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _primaryNeon.withOpacity(0.4),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow(isFa ? 'امتیاز نهایی' : 'Final Score', '$_score', _primaryNeon),
                                const Divider(color: Colors.white12, height: 20),
                                _buildSummaryRow(isFa ? 'بالاترین کمبو' : 'Max Combo', '${_maxCombo}x', _secondaryNeon),
                                const Divider(color: Colors.white12, height: 20),
                                _buildSummaryRow(isFa ? 'ضربات عالی (+3)' : 'Perfect (+3)', '$_perfectHits', Colors.amberAccent),
                                const Divider(color: Colors.white12, height: 20),
                                _buildSummaryRow(isFa ? 'ضربات خوب (+2)' : 'Good (+2)', '$_goodHits', _primaryNeon),
                                const Divider(color: Colors.white12, height: 20),
                                _buildSummaryRow(isFa ? 'خطاها (کاهش امتیاز)' : 'Misses (Score -2)', '$_missHits', Colors.redAccent),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryNeon,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: _startNewRound,
                                icon: const Icon(Icons.replay_rounded),
                                label: Text(
                                  isFa ? 'بازی مجدد' : 'PLAY AGAIN',
                                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                ),
                              ),
                              const SizedBox(width: 14),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white38),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.home_rounded),
                                label: Text(isFa ? 'منوی اصلی' : 'HOME'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TwoSparksPainter extends CustomPainter {
  final double alignProgress; // 0.0 (narrow) to 1.0 (wide)
  final double beatProgress;
  final double bgWarpPhase;
  final List<ObstacleGate> gates;
  final List<SparkParticleEffect> particles;
  final Color glowColor1;
  final Color glowColor2;
  final int combo;

  _TwoSparksPainter({
    required this.alignProgress,
    required this.beatProgress,
    required this.bgWarpPhase,
    required this.gates,
    required this.particles,
    required this.glowColor1,
    required this.glowColor2,
    required this.combo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);

    // 1. Draw Dark Neon Background & Radial Beat Pulses
    _drawBackground(canvas, size, center);

    // 2. Draw Speed Highway Tracks & Target Hit Zone
    _drawTracks(canvas, size);

    // 3. Draw Timed Obstacle Gates
    _drawObstacles(canvas, size);

    // 4. Draw Twin Glowing Orbs Moving Forward
    _drawTwinSparks(canvas, size);

    // 5. Draw Particle Sparks
    _drawParticles(canvas);
  }

  void _drawBackground(Canvas canvas, Size size, Offset center) {
    final bgPaint = Paint()..color = const Color(0xFF070B14);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Radial Beat Pulse Glow
    final pulseRadius = (size.width * 0.48) * (0.85 + beatProgress * 0.25);
    final radialGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor1.withOpacity(0.18 + (combo > 5 ? 0.1 : 0.0)),
          glowColor2.withOpacity(0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: pulseRadius));
    canvas.drawCircle(center, pulseRadius, radialGlow);

    // Perspective Cyber Grid Lines
    final gridPaint = Paint()
      ..color = glowColor1.withOpacity(0.08)
      ..strokeWidth = 1.0;

    for (double x = 0; x <= size.width; x += 40) {
      canvas.drawLine(Offset(x, size.height), Offset(center.dx, center.dy * 0.4), gridPaint);
    }
  }

  void _drawTracks(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glowing Target Hit-Line Zone (at 75% height)
    final targetY = h * 0.75;
    final hitLinePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, glowColor1.withOpacity(0.5), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, targetY - 2, w, 4))
      ..strokeWidth = 2.5;

    canvas.drawLine(Offset(w * 0.05, targetY), Offset(w * 0.95, targetY), hitLinePaint);

    // Side track borders
    final borderPaint = Paint()
      ..color = glowColor1.withOpacity(0.25)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.18, 0), Offset(w * 0.12, h), borderPaint);
    canvas.drawLine(Offset(w * 0.82, 0), Offset(w * 0.88, h), borderPaint);
  }

  void _drawObstacles(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (var gate in gates) {
      final y = gate.y * h;
      final scale = 0.55 + (gate.y * 0.55);

      switch (gate.type) {
        case GateType.splitOuter:
          // Center obstacle (Player must be WIDE)
          final obsColor = gate.resolved
              ? (gate.passedSuccessfully ? Colors.greenAccent : Colors.redAccent)
              : const Color(0xFFFFD600);

          final barrierW = 64.0 * scale;
          final barrierH = 22.0 * scale;
          final rrect = RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(w * 0.5, y), width: barrierW, height: barrierH),
            const Radius.circular(8),
          );

          canvas.drawRRect(rrect, Paint()..color = obsColor.withOpacity(0.85));
          canvas.drawRRect(
            rrect,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
          break;

        case GateType.narrowCenter:
          // Side obstacles (Player must be NARROW)
          final obsColor = gate.resolved
              ? (gate.passedSuccessfully ? Colors.greenAccent : Colors.redAccent)
              : const Color(0xFFFF007F);

          final wallW = 84.0 * scale;
          final wallH = 22.0 * scale;

          // Left Wall
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(w * 0.22, y), width: wallW, height: wallH),
              const Radius.circular(8),
            ),
            Paint()..color = obsColor.withOpacity(0.85),
          );
          // Right Wall
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(w * 0.78, y), width: wallW, height: wallH),
              const Radius.circular(8),
            ),
            Paint()..color = obsColor.withOpacity(0.85),
          );
          break;

        case GateType.beatPulseRing:
          // Timing Beat Ring
          final ringPaint = Paint()
            ..color = glowColor1.withOpacity(gate.resolved ? 0.4 : 0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0 * scale;
          canvas.drawCircle(Offset(w * 0.5, y), 54.0 * scale, ringPaint);
          break;

        case GateType.energyCrystal:
          // Bonus Crystal
          final gemPaint = Paint()..color = Colors.amberAccent;
          canvas.drawCircle(Offset(w * 0.5, y), 12.0 * scale, gemPaint);
          canvas.drawCircle(
            Offset(w * 0.5, y),
            6.0 * scale,
            Paint()..color = Colors.white,
          );
          break;
      }
    }
  }

  void _drawTwinSparks(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final targetY = h * 0.75;

    // Spacing between orbs: Narrow (40dp) <-> Wide (140dp)
    final orbSpacing = 40.0 + (alignProgress * 100.0);
    final orb1Pos = Offset((w * 0.5) - (orbSpacing * 0.5), targetY);
    final orb2Pos = Offset((w * 0.5) + (orbSpacing * 0.5), targetY);

    // Laser Connector Line between orbs
    final connectorPaint = Paint()
      ..shader = LinearGradient(colors: [glowColor1, glowColor2]).createShader(
        Rect.fromPoints(orb1Pos, orb2Pos),
      )
      ..strokeWidth = 3.5;
    canvas.drawLine(orb1Pos, orb2Pos, connectorPaint);

    // Trails behind orbs
    _drawTrail(canvas, orb1Pos, glowColor1);
    _drawTrail(canvas, orb2Pos, glowColor2);

    // Left Glowing Orb
    _drawSingleOrb(canvas, orb1Pos, glowColor1);

    // Right Glowing Orb
    _drawSingleOrb(canvas, orb2Pos, glowColor2);
  }

  void _drawTrail(Canvas canvas, Offset pos, Color color) {
    const trailLen = 50.0;
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [color.withOpacity(0.65), Colors.transparent],
      ).createShader(Rect.fromLTWH(pos.dx - 10, pos.dy - trailLen, 20, trailLen))
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(pos, Offset(pos.dx, pos.dy - trailLen), trailPaint);
  }

  void _drawSingleOrb(Canvas canvas, Offset pos, Color color) {
    // Outer Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(pos, 22, glowPaint);

    // Inner Core
    final corePaint = Paint()..color = color;
    canvas.drawCircle(pos, 14, corePaint);

    // Center Hotspot
    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(pos, 6, highlightPaint);
  }

  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TwoSparksPainter oldDelegate) => true;
}
