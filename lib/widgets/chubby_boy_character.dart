import 'dart:math' as math;
import 'package:flutter/material.dart';

class ChubbyBoyCharacter extends StatefulWidget {
  final double size;
  final Color? lineColor;
  final Color? skinColor;
  final Color? shirtColor;
  final Color? pantsColor;
  final Color? cheekColor;
  final bool enableIdleWobble;

  const ChubbyBoyCharacter({
    Key? key,
    this.size = 140,
    this.lineColor,
    this.skinColor,
    this.shirtColor,
    this.pantsColor,
    this.cheekColor,
    this.enableIdleWobble = true,
  }) : super(key: key);

  @override
  State<ChubbyBoyCharacter> createState() => _ChubbyBoyCharacterState();
}

class _ChubbyBoyCharacterState extends State<ChubbyBoyCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _jumpAnimation;
  late Animation<double> _squashAnimation;
  late Animation<double> _armAnimation;
  late Animation<double> _legAnimation;
  late Animation<double> _shadowScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);

    // Jump height translation (upward)
    _jumpAnimation = Tween<double>(begin: 0.0, end: -42.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
        reverseCurve: Curves.easeInQuad,
      ),
    );

    // Squash on landing, stretch on jump
    _squashAnimation = Tween<double>(begin: 0.88, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Arm flapping / cheering rotation
    _armAnimation = Tween<double>(begin: -0.25, end: 0.35).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Leg kick / bending
    _legAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Dynamic ground shadow
    _shadowScaleAnimation = Tween<double>(begin: 1.0, end: 0.45).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void disposeWidget() {
    _controller.dispose();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final lineCol = widget.lineColor ?? (isDark ? const Color(0xFFF2F2F7) : const Color(0xFF1C1C1E));
    final skinCol = widget.skinColor ?? const Color(0xFFFFDDBB);
    final shirtCol = widget.shirtColor ?? const Color(0xFF007AFF);
    final pantsCol = widget.pantsColor ?? const Color(0xFFFF2D55);
    final blushCol = widget.cheekColor ?? const Color(0xFFFF375F);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size + 45,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Floor Ground Shadow
              Positioned(
                bottom: 4,
                child: Transform.scale(
                  scaleX: _shadowScaleAnimation.value,
                  scaleY: 0.35,
                  child: Container(
                    width: widget.size * 0.58,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25 * _shadowScaleAnimation.value),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),

              // Chubby Boy Jumping Figure
              Positioned(
                bottom: 14,
                child: Transform.translate(
                  offset: Offset(0, _jumpAnimation.value),
                  child: Transform.scale(
                    scaleY: _squashAnimation.value,
                    scaleX: 2.0 - _squashAnimation.value,
                    alignment: Alignment.bottomCenter,
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _FullChubbyBoyPainter(
                        lineColor: lineCol,
                        skinColor: skinCol,
                        shirtColor: shirtCol,
                        pantsColor: pantsCol,
                        blushColor: blushCol,
                        armAngle: _armAnimation.value,
                        legBendProgress: _legAnimation.value,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FullChubbyBoyPainter extends CustomPainter {
  final Color lineColor;
  final Color skinColor;
  final Color shirtColor;
  final Color pantsColor;
  final Color blushColor;
  final double armAngle;
  final double legBendProgress;

  _FullChubbyBoyPainter({
    required this.lineColor,
    required this.skinColor,
    required this.shirtColor,
    required this.pantsColor,
    required this.blushColor,
    required this.armAngle,
    required this.legBendProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.2, w * 0.024)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final skinPaint = Paint()
      ..color = skinColor
      ..style = PaintingStyle.fill;

    final shirtPaint = Paint()
      ..color = shirtColor
      ..style = PaintingStyle.fill;

    final pantsPaint = Paint()
      ..color = pantsColor
      ..style = PaintingStyle.fill;

    final blushPaint = Paint()
      ..color = blushColor.withOpacity(0.55)
      ..style = PaintingStyle.fill;

    final shoePaint = Paint()
      ..color = const Color(0xFFFFCC00)
      ..style = PaintingStyle.fill;

    // -------------------------------------------------------------
    // 1. LEGS & SHOES (with feet kicking as he jumps)
    // -------------------------------------------------------------
    final legSpacing = w * 0.13;
    final leftLegX = w * 0.5 - legSpacing;
    final rightLegX = w * 0.5 + legSpacing;
    final legTopY = h * 0.76;
    final legBottomY = h * 0.90 + (legBendProgress * h * 0.04);

    // Left Leg & Pants Cuff
    final leftLegPath = Path();
    leftLegPath.moveTo(leftLegX - w * 0.06, legTopY);
    leftLegPath.lineTo(leftLegX - w * 0.05, legBottomY);
    leftLegPath.lineTo(leftLegX + w * 0.05, legBottomY);
    leftLegPath.lineTo(leftLegX + w * 0.06, legTopY);
    leftLegPath.close();
    canvas.drawPath(leftLegPath, pantsPaint);
    canvas.drawPath(leftLegPath, strokePaint);

    // Left Shoe (Yellow boot/sneaker)
    final leftShoe = RRect.fromRectAndRadius(
      Rect.fromLTWH(leftLegX - w * 0.10, legBottomY, w * 0.16, h * 0.08),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(leftShoe, shoePaint);
    canvas.drawRRect(leftShoe, strokePaint);

    // Right Leg & Pants Cuff
    final rightLegPath = Path();
    rightLegPath.moveTo(rightLegX - w * 0.06, legTopY);
    rightLegPath.lineTo(rightLegX - w * 0.05, legBottomY);
    rightLegPath.lineTo(rightLegX + w * 0.05, legBottomY);
    rightLegPath.lineTo(rightLegX + w * 0.06, legTopY);
    rightLegPath.close();
    canvas.drawPath(rightLegPath, pantsPaint);
    canvas.drawPath(rightLegPath, strokePaint);

    // Right Shoe (Yellow boot/sneaker)
    final rightShoe = RRect.fromRectAndRadius(
      Rect.fromLTWH(rightLegX - w * 0.06, legBottomY, w * 0.16, h * 0.08),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(rightShoe, shoePaint);
    canvas.drawRRect(rightShoe, strokePaint);

    // -------------------------------------------------------------
    // 2. CHUBBY ROUND BODY (Tummy / T-Shirt & Shorts)
    // -------------------------------------------------------------
    final bodyCenter = Offset(w * 0.5, h * 0.65);
    final bodyRadiusX = w * 0.30;
    final bodyRadiusY = h * 0.22;

    // Chubby Pear/Tummy Outline
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.28, h * 0.50);
    bodyPath.cubicTo(w * 0.16, h * 0.60, w * 0.18, h * 0.82, w * 0.50, h * 0.82);
    bodyPath.cubicTo(w * 0.82, h * 0.82, w * 0.84, h * 0.60, w * 0.72, h * 0.50);
    bodyPath.close();

    // Fill Shirt
    canvas.drawPath(bodyPath, shirtPaint);

    // Draw Pants overlay on bottom half of tummy
    final pantsBeltPath = Path();
    pantsBeltPath.moveTo(w * 0.22, h * 0.71);
    pantsBeltPath.quadraticBezierTo(w * 0.50, h * 0.75, w * 0.78, h * 0.71);
    pantsBeltPath.lineTo(w * 0.74, h * 0.82);
    pantsBeltPath.quadraticBezierTo(w * 0.50, h * 0.84, w * 0.26, h * 0.82);
    pantsBeltPath.close();
    canvas.drawPath(pantsBeltPath, pantsPaint);
    canvas.drawPath(pantsBeltPath, strokePaint);

    // Outer body line
    canvas.drawPath(bodyPath, strokePaint);

    // Cute star or logo on shirt
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.50, h * 0.60), w * 0.04, starPaint);

    // -------------------------------------------------------------
    // 3. ARMS & HANDS (Cheering in the air while jumping)
    // -------------------------------------------------------------
    // Left Arm
    canvas.save();
    canvas.translate(w * 0.28, h * 0.54);
    canvas.rotate(-0.5 + armAngle);
    final leftArmPath = Path();
    leftArmPath.moveTo(0, 0);
    leftArmPath.cubicTo(-w * 0.18, -h * 0.06, -w * 0.20, -h * 0.22, -w * 0.08, -h * 0.26);
    leftArmPath.lineTo(-w * 0.02, -h * 0.22);
    leftArmPath.cubicTo(-w * 0.10, -h * 0.16, -w * 0.08, -h * 0.04, w * 0.04, 0);
    leftArmPath.close();
    canvas.drawPath(leftArmPath, shirtPaint);
    canvas.drawPath(leftArmPath, strokePaint);
    // Left Chubby Hand (fist/palm)
    canvas.drawCircle(Offset(-w * 0.05, -h * 0.25), w * 0.05, skinPaint);
    canvas.drawCircle(Offset(-w * 0.05, -h * 0.25), w * 0.05, strokePaint);
    canvas.restore();

    // Right Arm
    canvas.save();
    canvas.translate(w * 0.72, h * 0.54);
    canvas.rotate(0.5 - armAngle);
    final rightArmPath = Path();
    rightArmPath.moveTo(0, 0);
    rightArmPath.cubicTo(w * 0.18, -h * 0.06, w * 0.20, -h * 0.22, w * 0.08, -h * 0.26);
    rightArmPath.lineTo(w * 0.02, -h * 0.22);
    rightArmPath.cubicTo(w * 0.10, -h * 0.16, w * 0.08, -h * 0.04, -w * 0.04, 0);
    rightArmPath.close();
    canvas.drawPath(rightArmPath, shirtPaint);
    canvas.drawPath(rightArmPath, strokePaint);
    // Right Chubby Hand (fist/palm)
    canvas.drawCircle(Offset(w * 0.05, -h * 0.25), w * 0.05, skinPaint);
    canvas.drawCircle(Offset(w * 0.05, -h * 0.25), w * 0.05, strokePaint);
    canvas.restore();

    // -------------------------------------------------------------
    // 4. ROUND CHUBBY HEAD & CHEEKS
    // -------------------------------------------------------------
    final headCenter = Offset(w * 0.50, h * 0.34);
    final headRadius = w * 0.25;

    // Ears
    canvas.drawCircle(Offset(w * 0.26, h * 0.35), w * 0.06, skinPaint);
    canvas.drawCircle(Offset(w * 0.26, h * 0.35), w * 0.06, strokePaint);
    canvas.drawCircle(Offset(w * 0.74, h * 0.35), w * 0.06, skinPaint);
    canvas.drawCircle(Offset(w * 0.74, h * 0.35), w * 0.06, strokePaint);

    // Head circle
    canvas.drawCircle(headCenter, headRadius, skinPaint);
    canvas.drawCircle(headCenter, headRadius, strokePaint);

    // -------------------------------------------------------------
    // 5. CUTE HAIR TUFTS & CAP
    // -------------------------------------------------------------
    final hairPaint = Paint()
      ..color = const Color(0xFF4A3728) // Warm Brown Hair
      ..style = PaintingStyle.fill;

    final hairPath = Path();
    hairPath.moveTo(w * 0.27, h * 0.30);
    hairPath.quadraticBezierTo(w * 0.28, h * 0.12, w * 0.50, h * 0.12);
    hairPath.quadraticBezierTo(w * 0.72, h * 0.12, w * 0.73, h * 0.30);
    hairPath.quadraticBezierTo(w * 0.65, h * 0.22, w * 0.50, h * 0.24);
    hairPath.quadraticBezierTo(w * 0.35, h * 0.22, w * 0.27, h * 0.30);
    hairPath.close();
    canvas.drawPath(hairPath, hairPaint);
    canvas.drawPath(hairPath, strokePaint);

    // Front cute hair strand
    final hairSpike = Path();
    hairSpike.moveTo(w * 0.44, h * 0.12);
    hairSpike.quadraticBezierTo(w * 0.50, h * 0.04, w * 0.56, h * 0.13);
    canvas.drawPath(hairSpike, strokePaint);

    // -------------------------------------------------------------
    // 6. JOYFUL EYES (^ ^) & EYEBROWS
    // -------------------------------------------------------------
    final eyePaint = Paint()
      ..color = const Color(0xFF1C1C1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.8, w * 0.03)
      ..strokeCap = StrokeCap.round;

    // Left Joyful Eye
    final leftEye = Path();
    leftEye.moveTo(w * 0.39, h * 0.33);
    leftEye.quadraticBezierTo(w * 0.43, h * 0.29, w * 0.47, h * 0.33);
    canvas.drawPath(leftEye, eyePaint);

    // Right Joyful Eye
    final rightEye = Path();
    rightEye.moveTo(w * 0.53, h * 0.33);
    rightEye.quadraticBezierTo(w * 0.57, h * 0.29, w * 0.61, h * 0.33);
    canvas.drawPath(rightEye, eyePaint);

    // Eyebrows
    canvas.drawLine(Offset(w * 0.39, h * 0.26), Offset(w * 0.45, h * 0.25), eyePaint);
    canvas.drawLine(Offset(w * 0.61, h * 0.26), Offset(w * 0.55, h * 0.25), eyePaint);

    // -------------------------------------------------------------
    // 7. ROSY BLUSH CHEEKS
    // -------------------------------------------------------------
    canvas.drawCircle(Offset(w * 0.35, h * 0.38), w * 0.048, blushPaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.38), w * 0.048, blushPaint);

    // Cute Nose
    canvas.drawCircle(Offset(w * 0.50, h * 0.35), w * 0.015, eyePaint);

    // -------------------------------------------------------------
    // 8. WIDE OPEN HAPPY MOUTH (Singing / Cheering)
    // -------------------------------------------------------------
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.44, h * 0.38);
    mouthPath.quadraticBezierTo(w * 0.50, h * 0.47, w * 0.56, h * 0.38);
    mouthPath.close();

    final mouthFill = Paint()..color = const Color(0xFFFF2D55);
    canvas.drawPath(mouthPath, mouthFill);
    canvas.drawPath(mouthPath, strokePaint);

    // Tongue
    final tonguePath = Path();
    tonguePath.moveTo(w * 0.47, h * 0.43);
    tonguePath.quadraticBezierTo(w * 0.50, h * 0.46, w * 0.53, h * 0.43);
    tonguePath.close();
    final tongueFill = Paint()..color = const Color(0xFFFF9500);
    canvas.drawPath(tonguePath, tongueFill);
  }

  @override
  bool shouldRepaint(covariant _FullChubbyBoyPainter oldDelegate) {
    return oldDelegate.armAngle != armAngle ||
        oldDelegate.legBendProgress != legBendProgress ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.shirtColor != shirtColor ||
        oldDelegate.pantsColor != pantsColor;
  }
}
