import 'package:flutter/material.dart';

class MadoyarLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? glowColor;

  const MadoyarLogo({
    Key? key,
    this.size = 100,
    this.showText = true,
    this.glowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = glowColor ?? theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [primary.withOpacity(0.2), secondary.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: primary.withOpacity(0.8),
              width: 2.5,
            ),
          ),
          child: CustomPaint(
            painter: _MadoyarEmblemPainter(primary: primary, secondary: secondary),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [primary, secondary, theme.colorScheme.tertiary],
            ).createShader(bounds),
            child: const Text(
              'MADOYAR',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'STUDIOS & GAMES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.0,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ]
      ],
    );
  }
}

class _MadoyarEmblemPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  _MadoyarEmblemPainter({required this.primary, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw stylized dynamic 'M' and spark wings
    final paintM = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pathM = Path();
    final w = size.width;
    final h = size.height;

    // Outer stylized wings
    pathM.moveTo(w * 0.28, h * 0.68);
    pathM.lineTo(w * 0.30, h * 0.36);
    pathM.lineTo(w * 0.50, h * 0.54);
    pathM.lineTo(w * 0.70, h * 0.36);
    pathM.lineTo(w * 0.72, h * 0.68);

    canvas.drawPath(pathM, paintM);

    // Glowing Central Diamond Spark
    final diamondPaint = Paint()
      ..color = secondary
      ..style = PaintingStyle.fill;

    final sparkPath = Path();
    sparkPath.moveTo(w * 0.50, h * 0.22);
    sparkPath.lineTo(w * 0.56, h * 0.32);
    sparkPath.lineTo(w * 0.50, h * 0.42);
    sparkPath.lineTo(w * 0.44, h * 0.32);
    sparkPath.close();

    canvas.drawPath(sparkPath, diamondPaint);

    // Dynamic accent sparks
    final sparkPointPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.28, h * 0.72), 3, sparkPointPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.72), 3, sparkPointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
