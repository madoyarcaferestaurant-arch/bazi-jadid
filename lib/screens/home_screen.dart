import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../widgets/chubby_boy_character.dart';
import '../widgets/floating_jumping_boy.dart';
import '../widgets/madoyar_logo.dart';
import 'two_sparks_game_screen.dart';
import 'hokm_game_screen.dart';
import 'gems_game_screen.dart';
import 'ricochlime_game_screen.dart';
import 'neon_asteroids_game_screen.dart';
import 'maplestory_game_screen.dart';
import 'beehoney_game_screen.dart';
import 'treasure_hunt_game_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppSettings settings;

  const HomeScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const isFa = true;

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            // Apple-style ambient ambient mesh background
            Positioned(
              top: -60,
              right: isFa ? null : -60,
              left: isFa ? -60 : null,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF007AFF).withOpacity(isDark ? 0.18 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 240,
              left: isFa ? null : -80,
              right: isFa ? -80 : null,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFAF52DE).withOpacity(isDark ? 0.14 : 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Scrollable Content
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // iOS Large Title Navigation Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Apple Squircle Logo Container
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1C1C1E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.12)
                                    : Colors.black.withOpacity(0.06),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.3 : 0.06,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const MadoyarLogo(size: 34, showText: false),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFa ? 'مادویار' : 'Madoyar',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                    color: theme.colorScheme.onBackground,
                                  ),
                                ),
                                Text(
                                  isFa
                                      ? 'مرکز سرگرمی و بازی‌های کافه'
                                      : 'Entertainment & Games Hub',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.2,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // iOS Frosted Settings Pill Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                widget.settings.playUiFeedback();
                                Navigator.of(context).pushNamed('/settings');
                              },
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2C2C2E)
                                      : const Color(0xFFE5E5EA),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.settings_outlined,
                                  size: 21,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Hero Featured Card (Apple App Store Spotlight Style)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 6.0,
                      ),
                      child: _buildAppleHeroCard(context),
                    ),
                  ),

                  // Section Header: Games & Activities
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
                      child: Row(
                        children: [
                          Text(
                            isFa ? 'بازی‌ها و امکانات' : 'GAMES & ACTIVITIES',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: isFa ? 0.0 : 0.8,
                              color: isDark
                                  ? const Color(0xFF8E8E93)
                                  : const Color(0xFF6E6E73),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Apple Inset Grouped List of Items
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1C1C1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.05),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.25 : 0.04,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // 1. Two Sparks: Pulse Mode
                              _buildIosListItem(
                                context,
                                title: widget.settings.tr('two_sparks'),
                                subtitle: widget.settings.tr('two_sparks_sub'),
                                icon: Icons.electric_bolt_rounded,
                                iconColors: [
                                  const Color(0xFFFF2D55),
                                  const Color(0xFFFF9500),
                                ],
                                actionBadge: isFa ? 'شروع بازی' : 'PLAY',
                                showDivider: true,
                                onTap: () {
                                  widget.settings.playUiFeedback();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TwoSparksGameScreen(
                                        settings: widget.settings,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // 2. Hokm Card Game
                              _buildIosListItem(
                                context,
                                title: widget.settings.tr('hokm_game'),
                                subtitle: widget.settings.tr('hokm_sub'),
                                icon: Icons.style_rounded,
                                iconColors: [
                                  const Color(0xFF5856D6),
                                  const Color(0xFF007AFF),
                                ],
                                actionBadge: isFa ? 'شروع بازی' : 'PLAY',
                                showDivider: true,
                                onTap: () {
                                  widget.settings.playUiFeedback();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HokmGameScreen(
                                        settings: widget.settings,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // 3. Gems
                              _buildIosListItem(
                                context,
                                title: 'Gems',
                                subtitle: 'جواهرات را جور کنید و امتیاز بگیرید',
                                icon: Icons.diamond_rounded,
                                iconColors: [
                                  const Color(0xFFAF52DE),
                                  const Color(0xFF5856D6),
                                ],
                                actionBadge: isFa ? 'بازی' : 'PLAY',
                                showDivider: true,
                                onTap: () {
                                  widget.settings.playUiFeedback();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => GemsGameScreen(
                                        settings: widget.settings,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              _buildIosListItem(
                                context,
                                title: 'سیارک‌های نئونی',
                                subtitle: 'شلیک، موج‌ها و قدرت‌های ویژه',
                                icon: Icons.rocket_launch_rounded,
                                iconColors: [
                                  const Color(0xFF00C7BE),
                                  const Color(0xFF5856D6),
                                ],
                                actionBadge: 'بازی',
                                showDivider: true,
                                onTap: () {
                                  widget.settings.playUiFeedback();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => NeonAsteroidsGameScreen(
                                        settings: widget.settings,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // 5. Ricochlime
                              _buildIosListItem(
                                context,
                                title: 'Ricochlime',
                                subtitle: isFa
                                    ? 'با لایم سبز به دیواره‌ها ضربه بزنید'
                                    : 'Keep the lime bouncing',
                                icon: Icons.sports_esports_rounded,
                                iconColors: [
                                  const Color(0xFF30D158),
                                  const Color(0xFF00A896),
                                ],
                                actionBadge: isFa ? 'بازی' : 'PLAY',
                                showDivider: true,
                                onTap: () {
                                  widget.settings.playUiFeedback(isHeavy: true);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => RicochlimeGameScreen(
                                        settings: widget.settings,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              _buildIosListItem(
                                context,
                                title: 'MapleStory',
                                subtitle: 'ماجراجویی در سرزمین قارچ‌ها',
                                icon: Icons.park_rounded,
                                iconColors: [
                                  const Color(0xFF34C759),
                                  const Color(0xFF30B0C7),
                                ],
                                actionBadge: 'بازی',
                                showDivider: true,
                                onTap: () {
                                  widget.settings.playUiFeedback(isHeavy: true);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => MapleStoryGameScreen(
                                        settings: widget.settings,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              _buildIosListItem(
                                context,
                                title: 'Beehoney',
                                subtitle: 'پرواز زنبور و جمع‌آوری گل‌ها',
                                icon: Icons.local_florist_rounded,
                                iconColors: [
                                  const Color(0xFFFFCC00),
                                  const Color(0xFFFF9500),
                                ],
                                actionBadge: 'بازی',
                                showDivider: true,
                                onTap: () {
                                  widget.settings.playUiFeedback();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BeeHoneyGameScreen(
                                        settings: widget.settings,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              _buildIosListItem(
                                context,
                                title: 'Treasure Hunt Adventure',
                                subtitle:
                                    'گنجینه‌ها را پیدا کنید و زنده بمانید',
                                icon: Icons.explore_rounded,
                                iconColors: [
                                  const Color(0xFFFF9500),
                                  const Color(0xFFFF2D55),
                                ],
                                actionBadge: 'بازی',
                                showDivider: true,
                                onTap: () {
                                  widget.settings.playUiFeedback(isHeavy: true);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TreasureHuntGameScreen(
                                        settings: widget.settings,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // 4. About Us
                              _buildIosListItem(
                                context,
                                title: widget.settings.tr('about_us'),
                                subtitle: widget.settings.tr('about_us_sub'),
                                icon: Icons.storefront_rounded,
                                iconColors: [
                                  const Color(0xFF34C759),
                                  const Color(0xFF30B0C7),
                                ],
                                actionBadge: isFa ? 'اطلاعات' : 'VIEW',
                                showDivider: true,
                                onTap: () {
                                  widget.settings.playUiFeedback();
                                  Navigator.of(context).pushNamed('/about');
                                },
                              ),

                              // 5. Settings
                              _buildIosListItem(
                                context,
                                title: widget.settings.tr('settings'),
                                subtitle: widget.settings.tr('settings_sub'),
                                icon: Icons.tune_rounded,
                                iconColors: [
                                  const Color(0xFFFF9500),
                                  const Color(0xFFFFCC00),
                                ],
                                actionBadge: isFa ? 'تنظیمات' : 'EDIT',
                                showDivider: false,
                                onTap: () {
                                  widget.settings.playUiFeedback();
                                  Navigator.of(context).pushNamed('/settings');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),

            // Chubby Boy bouncing and jumping across the whole HomeScreen
            FloatingJumpingBoy(
              onTap: () {
                widget.settings.playUiFeedback();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFa = widget.settings.isPersian;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1F2838), const Color(0xFF141923)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF2F6FC)],
        ),
        border: Border.all(
          color: isDark
              ? const Color(0xFF007AFF).withOpacity(0.3)
              : const Color(0xFF007AFF).withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withOpacity(isDark ? 0.15 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          widget.settings.tr('welcome_badge'),
                          style: const TextStyle(
                            color: Color(0xFF007AFF),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.settings.tr('welcome_title'),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.settings.tr('welcome_sub'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                          color: theme.colorScheme.onSurface.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Chubby Boy Mascot
                const SizedBox(
                  width: 110,
                  height: 120,
                  child: ChubbyBoyCharacter(size: 95),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIosListItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> iconColors,
    required String actionBadge,
    required bool showDivider,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFa = widget.settings.isPersian;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 13.0,
              ),
              child: Row(
                children: [
                  // Apple Squircle App Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: iconColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: iconColors.first.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.1,
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.55,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Apple Store Style Action Pill
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          actionBadge,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF007AFF),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  Icon(
                    isFa
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    size: 18,
                    color: isDark
                        ? const Color(0xFF48484A)
                        : const Color(0xFFC7C7CC),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(
              left: isFa ? 0 : 74.0,
              right: isFa ? 74.0 : 0,
            ),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
            ),
          ),
      ],
    );
  }
}
