import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/hokm_models.dart';

class PersianCardWidget extends StatelessWidget {
  final PlayingCard? card;
  final bool isFaceUp;
  final bool isPlayable;
  final bool isSelected;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool showPersianLabels;

  const PersianCardWidget({
    Key? key,
    this.card,
    this.isFaceUp = true,
    this.isPlayable = true,
    this.isSelected = false,
    this.onTap,
    this.width = 64,
    this.height = 96,
    this.showPersianLabels = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width;
    final effectiveHeight = height;

    Widget cardContent;
    if (!isFaceUp || card == null) {
      cardContent = _buildCardBack(effectiveWidth, effectiveHeight);
    } else {
      cardContent = _buildCardFace(context, card!, effectiveWidth, effectiveHeight);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, isSelected ? -14 : 0, 0),
      child: GestureDetector(
        onTap: isPlayable ? onTap : null,
        child: Container(
          width: effectiveWidth,
          height: effectiveHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(effectiveWidth * 0.12),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFFFFD700).withOpacity(0.6)
                    : (isPlayable
                        ? Colors.black.withOpacity(0.25)
                        : Colors.black.withOpacity(0.1)),
                blurRadius: isSelected ? 12 : 6,
                spreadRadius: isSelected ? 2 : 0,
                offset: Offset(0, isSelected ? 6 : 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(effectiveWidth * 0.12),
            child: Opacity(
              opacity: isPlayable || !isFaceUp ? 1.0 : 0.65,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(width: effectiveWidth, height: effectiveHeight, child: cardContent),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace(
    BuildContext context,
    PlayingCard c,
    double w,
    double h,
  ) {
    final suitColor = Color(c.suit.colorHex);
    final isCourt = c.rank.value >= 11;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7), // Warm minimal ivory silk paper
        border: Border.all(
          color: isSelected ? const Color(0xFFFFD700) : const Color(0xFFE2D9C8),
          width: isSelected ? 2.0 : 1.2,
        ),
      ),
      child: Stack(
        children: [
          // Subtle Persian corner filigree
          Positioned(
            top: 2,
            right: 2,
            child: Opacity(
              opacity: 0.18,
              child: Icon(Icons.star_rounded, size: w * 0.18, color: const Color(0xFFB8860B)),
            ),
          ),

          // Top Left Rank & Suit
          Positioned(
            top: h * 0.05,
            left: w * 0.08,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  c.rank.label,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: w * 0.24,
                    fontWeight: FontWeight.w900,
                    color: suitColor,
                    height: 1.0,
                  ),
                ),
                Text(
                  c.suit.symbol,
                  style: TextStyle(
                    fontSize: w * 0.22,
                    color: suitColor,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // Center Graphic / Court Emblem
          Center(
            child: isCourt
                ? _buildCourtEmblem(c, w, suitColor)
                : Text(
                    c.suit.symbol,
                    style: TextStyle(
                      fontSize: w * 0.46,
                      color: suitColor.withOpacity(0.9),
                    ),
                  ),
          ),

          // Bottom Right Inverted Rank & Suit
          Positioned(
            bottom: h * 0.05,
            right: w * 0.08,
            child: Transform.rotate(
              angle: math.pi,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    c.rank.label,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: w * 0.24,
                      fontWeight: FontWeight.w900,
                      color: suitColor,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    c.suit.symbol,
                    style: TextStyle(
                      fontSize: w * 0.22,
                      color: suitColor,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtEmblem(PlayingCard c, double w, Color suitColor) {
    String crownTitle = '';
    IconData emblemIcon = Icons.shield_rounded;

    switch (c.rank) {
      case CardRank.jack:
        crownTitle = 'J';
        emblemIcon = Icons.military_tech_rounded;
        break;
      case CardRank.queen:
        crownTitle = 'Q';
        emblemIcon = Icons.spa_rounded;
        break;
      case CardRank.king:
        crownTitle = 'K';
        emblemIcon = Icons.workspace_premium_rounded;
        break;
      case CardRank.ace:
        crownTitle = 'A';
        emblemIcon = Icons.diamond_rounded;
        break;
      default:
        break;
    }

    return Container(
      width: w * 0.54,
      height: w * 0.54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: suitColor.withOpacity(0.08),
        border: Border.all(color: suitColor.withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: FittedBox(child: Icon(emblemIcon, size: w * 0.24, color: suitColor))),
          Flexible(
            child: FittedBox(
              child: Text(c.suit.symbol, style: TextStyle(fontSize: w * 0.18, color: suitColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(double w, double h) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F2A3F), // Persian Turquoise / Deep Lapis Blue
            Color(0xFF0A1926),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5), // Gold trim
      ),
      child: CustomPaint(
        painter: _PersianTileBackPainter(),
      ),
    );
  }
}

class _PersianTileBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final turquoiseFill = Paint()
      ..color = const Color(0xFF00A896).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Outer margin border
    final insetRect = Rect.fromLTWH(4, 4, w - 8, h - 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(insetRect, const Radius.circular(4)),
      goldPaint,
    );

    // Central Persian Diamond Medallion (Toranj)
    final medallionPath = Path();
    medallionPath.moveTo(center.dx, center.dy - h * 0.22);
    medallionPath.lineTo(center.dx + w * 0.28, center.dy);
    medallionPath.lineTo(center.dx, center.dy + h * 0.22);
    medallionPath.lineTo(center.dx - w * 0.28, center.dy);
    medallionPath.close();

    canvas.drawPath(medallionPath, turquoiseFill);
    canvas.drawPath(medallionPath, goldPaint);

    // Center star flower
    final centerStar = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, centerStar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
