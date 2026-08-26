import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'chubby_boy_character.dart';

/// An interactive, floating chubby boy that can bounce, jump, walk around,
/// or be dragged across the entire screen in HomeScreen.
class FloatingJumpingBoy extends StatefulWidget {
  final VoidCallback? onTap;

  const FloatingJumpingBoy({Key? key, this.onTap}) : super(key: key);

  @override
  State<FloatingJumpingBoy> createState() => _FloatingJumpingBoyState();
}

class _FloatingJumpingBoyState extends State<FloatingJumpingBoy>
    with TickerProviderStateMixin {
  // Controller for continuous jumping up and down
  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;

  // Controller for horizontal wandering / walking across the screen
  late AnimationController _wanderController;
  late Animation<double> _wanderAnimation;

  // Track if dragged by user
  Offset? _customPosition;
  bool _isInteracting = false;
  bool _isSpeaking = false;
  String _speechText = '';

  final List<String> _phrases = [
    'سلام! بیا بازی کنیم! 🎮',
    'کافه مادویار عالیه! ☕✨',
    'حکم بزنیم یا دو جرقه؟ 🃏🔥',
    'هورااا! بالا پایین بپر! 🎈',
    'خوش اومدی دوست من! 😄',
    'من پسرک پرانرژی مادویارم! 🏃‍♂️',
  ];
  int _phraseIndex = 0;

  @override
  void initState() {
    super.initState();

    // 1. Jump up and down animation
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _jumpAnimation = Tween<double>(begin: 0.0, end: -35.0).animate(
      CurvedAnimation(
        parent: _jumpController,
        curve: Curves.easeOutQuad,
        reverseCurve: Curves.easeInQuad,
      ),
    );

    // 2. Horizontal smooth wandering across the screen
    _wanderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _wanderAnimation = Tween<double>(begin: 0.15, end: 0.85).animate(
      CurvedAnimation(
        parent: _wanderController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _wanderController.dispose();
    super.dispose();
  }

  void _onBoyTapped() {
    setState(() {
      _isSpeaking = true;
      _speechText = _phrases[_phraseIndex % _phrases.length];
      _phraseIndex++;
    });

    widget.onTap?.call();

    // Speed up jump briefly when tapped
    _jumpController.duration = const Duration(milliseconds: 380);
    _jumpController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
        _jumpController.duration = const Duration(milliseconds: 700);
        _jumpController.repeat(reverse: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boySize = 90.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_jumpAnimation, _wanderAnimation]),
      builder: (context, child) {
        // Calculate dynamic position (or user dragged position)
        final screenWidth = size.width;
        final screenHeight = size.height;

        double left;
        double bottom;

        if (_customPosition != null) {
          left = _customPosition!.dx.clamp(10.0, screenWidth - boySize - 10.0);
          bottom = (screenHeight - _customPosition!.dy - boySize)
              .clamp(20.0, screenHeight - boySize - 60.0);
        } else {
          left = (screenWidth - boySize) * _wanderAnimation.value;
          bottom = 16.0; // Anchored at bottom of screen
        }

        // Apply jump offset
        final currentBottom = bottom + (_jumpAnimation.value * -1);

        return Positioned(
          left: left,
          bottom: currentBottom,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _isInteracting = true;
                _customPosition = details.globalPosition - Offset(boySize / 2, boySize / 2);
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _customPosition = details.globalPosition - Offset(boySize / 2, boySize / 2);
              });
            },
            onPanEnd: (_) {
              setState(() {
                _isInteracting = false;
              });
              // Return to walking mode after 6 seconds of inactivity
              Future.delayed(const Duration(seconds: 5), () {
                if (mounted && !_isInteracting) {
                  setState(() {
                    _customPosition = null;
                  });
                }
              });
            },
            onTap: _onBoyTapped,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Speech Bubble Popup
                AnimatedOpacity(
                  opacity: _isSpeaking ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF007AFF).withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      _speechText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                ),

                // Chubby Boy character with full body, arms, legs, clothes and shadow
                ChubbyBoyCharacter(
                  size: boySize,
                  shirtColor: const Color(0xFF007AFF),
                  pantsColor: const Color(0xFFFF2D55),
                  skinColor: const Color(0xFFFFDDBB),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
