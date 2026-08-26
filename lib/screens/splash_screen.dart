import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/madoyar_logo.dart';
import '../models/app_settings.dart';

class SplashScreen extends StatefulWidget {
  final AppSettings? settings;

  const SplashScreen({Key? key, this.settings}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();

    _navigationTimer = Timer(const Duration(seconds: 5), () {
      _goToHome();
    });
  }

  void _goToHome() {
    _navigationTimer?.cancel();
    if (mounted) {
      widget.settings?.playUiFeedback();
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: GestureDetector(
          onTap: null,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Subtle ambient glow
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF007AFF).withOpacity(isDark ? 0.12 : 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Center(
                      child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.sizeOf(context).height -
                              MediaQuery.paddingOf(context).vertical - 64,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                          // Apple Squircle Logo
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.12)
                                    : Colors.black.withOpacity(0.06),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const MadoyarLogo(
                              size: 86,
                              showText: false,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // App Title
                          Text(
                            'مادویار',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'کافه و رستوران مادویار',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.2,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Location Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1C1C1E).withOpacity(0.8)
                                  : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: Color(0xFFFF3B30),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                    'مهرشهر، بلوار ارم، خیابان ۲۱۷',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.1,
                                    color: theme.colorScheme.onSurface.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),

                            const SizedBox(height: 28),

                          // Apple minimalist progress spinner
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
