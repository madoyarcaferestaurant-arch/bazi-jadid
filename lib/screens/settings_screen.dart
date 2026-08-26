import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../theme/app_themes.dart';

class SettingsScreen extends StatelessWidget {
  final AppSettings settings;

  const SettingsScreen({Key? key, required this.settings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFa = settings.isPersian;

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            settings.tr('settings'),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: theme.colorScheme.onBackground,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              isFa ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: const Color(0xFF007AFF),
            ),
            onPressed: () {
              settings.playUiFeedback();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: settings,
            builder: (context, _) {
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: [
                  // Section 1: Themes
                  _buildSectionHeader(
                    title: settings.tr('theme_section').toUpperCase(),
                    isDark: isDark,
                    isFa: isFa,
                  ),
                  const SizedBox(height: 8),
                  _buildThemeSegmentedCard(context),

                  const SizedBox(height: 28),

                  // Section 2: Language
                  _buildSectionHeader(
                    title: settings.tr('lang_section').toUpperCase(),
                    isDark: isDark,
                    isFa: isFa,
                  ),
                  const SizedBox(height: 8),
                  _buildLanguageGroupCard(context),

                  const SizedBox(height: 28),

                  // Section 3: Effects & Controls
                  _buildSectionHeader(
                    title: settings.tr('effects_section').toUpperCase(),
                    isDark: isDark,
                    isFa: isFa,
                  ),
                  const SizedBox(height: 8),
                  _buildControlsGroupCard(context),

                  const SizedBox(height: 36),

                  // Apple Footer Text
                  Center(
                    child: Text(
                      isFa ? 'اپلیکیشن کافه مادویار • نسخه ۱.۰.۰' : 'Madoyar Café App • Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required bool isDark,
    required bool isFa,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isFa ? 12.0 : 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: isFa ? 0.0 : 0.6,
          color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73),
        ),
      ),
    );
  }

  Widget _buildGroupContainer(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildThemeSegmentedCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final themeOptions = [
      {
        'type': AppThemeType.neonDark,
        'name': settings.tr('theme_neon_dark'),
        'color1': const Color(0xFF0A84FF),
        'color2': const Color(0xFFFF375F),
      },
      {
        'type': AppThemeType.neonLight,
        'name': settings.tr('theme_neon_light'),
        'color1': const Color(0xFF007AFF),
        'color2': const Color(0xFFFF2D55),
      },
      {
        'type': AppThemeType.classicMinimal,
        'name': settings.tr('theme_classic_minimal'),
        'color1': const Color(0xFFE5E5EA),
        'color2': const Color(0xFF8E8E93),
      },
      {
        'type': AppThemeType.warmColdDual,
        'name': settings.tr('theme_warm_cold'),
        'color1': const Color(0xFFFF9F0A),
        'color2': const Color(0xFF64D2FF),
      },
    ];

    return _buildGroupContainer(
      context,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: themeOptions.length,
            itemBuilder: (context, index) {
              final option = themeOptions[index];
              final type = option['type'] as AppThemeType;
              final name = option['name'] as String;
              final color1 = option['color1'] as Color;
              final color2 = option['color2'] as Color;
              final isSelected = settings.themeType == type;

              return InkWell(
                onTap: () => settings.setTheme(type),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF007AFF)
                          : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [color1, color2]),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color1.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: -0.2,
                            color: isSelected
                                ? (isDark ? Colors.white : const Color(0xFF007AFF))
                                : theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Color(0xFF007AFF),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageGroupCard(BuildContext context) {
    final isFa = settings.isPersian;

    return _buildGroupContainer(
      context,
      children: [
        _buildIosSettingRow(
          context,
          icon: Icons.language_rounded,
          iconColor: const Color(0xFF007AFF),
          title: 'English (US)',
          subtitle: 'English Interface',
          isSelected: settings.language == AppLanguage.english,
          showDivider: true,
          onTap: () => settings.setLanguage(AppLanguage.english),
        ),
        _buildIosSettingRow(
          context,
          icon: Icons.translate_rounded,
          iconColor: const Color(0xFF5856D6),
          title: 'فارسی (Persian)',
          subtitle: 'رابط کاربری زبان پارسی',
          isSelected: settings.language == AppLanguage.persian,
          showDivider: false,
          onTap: () => settings.setLanguage(AppLanguage.persian),
        ),
      ],
    );
  }

  Widget _buildControlsGroupCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFa = settings.isPersian;

    return _buildGroupContainer(
      context,
      children: [
        // 1. Touch Me! Toggle
        _buildIosSwitchRow(
          context,
          icon: Icons.touch_app_rounded,
          iconColor: const Color(0xFFFF9500),
          title: settings.tr('touch_me'),
          subtitle: settings.tr('touch_me_sub'),
          value: settings.touchMeParticles,
          onChanged: (val) => settings.setTouchMeParticles(val),
          showDivider: true,
        ),

        if (settings.touchMeParticles) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF007AFF)),
                    const SizedBox(width: 6),
                    Text(
                      settings.tr('particle_style'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007AFF),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildApplePillChip(
                        context,
                        type: ParticleEffectType.fireworks,
                        title: settings.tr('particle_fireworks'),
                        icon: Icons.flare_rounded,
                        accentColor: const Color(0xFFFF2D55),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildApplePillChip(
                        context,
                        type: ParticleEffectType.snow,
                        title: settings.tr('particle_snow'),
                        icon: Icons.ac_unit_rounded,
                        accentColor: const Color(0xFF007AFF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildApplePillChip(
                        context,
                        type: ParticleEffectType.random,
                        title: settings.tr('particle_mix'),
                        icon: Icons.auto_awesome_rounded,
                        accentColor: const Color(0xFFFFCC00),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: isFa ? 0 : 54, right: isFa ? 54 : 0),
            child: Divider(height: 0.5, thickness: 0.5, color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA)),
          ),
        ],

        // 2. Sound Effects
        _buildIosSwitchRow(
          context,
          icon: Icons.volume_up_rounded,
          iconColor: const Color(0xFF34C759),
          title: settings.tr('sound_effects'),
          subtitle: settings.tr('sound_sub'),
          value: settings.soundEnabled,
          onChanged: (val) => settings.setSoundEnabled(val),
          showDivider: true,
        ),

        // 3. Music
        _buildIosSwitchRow(
          context,
          icon: Icons.music_note_rounded,
          iconColor: const Color(0xFFAF52DE),
          title: settings.tr('music'),
          subtitle: settings.tr('music_sub'),
          value: settings.musicEnabled,
          onChanged: (val) => settings.setMusicEnabled(val),
          showDivider: true,
        ),

        // 4. Haptic Feedback
        _buildIosSwitchRow(
          context,
          icon: Icons.vibration_rounded,
          iconColor: const Color(0xFF5856D6),
          title: settings.tr('haptics'),
          subtitle: settings.tr('haptics_sub'),
          value: settings.hapticEnabled,
          onChanged: (val) => settings.setHapticEnabled(val),
          showDivider: false,
        ),
        const Divider(height: 0.5),
        _buildGamePreferences(context),
      ],
    );
  }

  Widget _buildGamePreferences(BuildContext context) {
    final isFa = settings.isPersian;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isFa ? 'تنظیمات بازی' : 'Game preferences', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isFa ? 'سرعت بازی' : 'Game speed'),
              Text('${settings.gameSpeed.toStringAsFixed(1)}x', style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: settings.gameSpeed,
            min: 0.7,
            max: 1.6,
            divisions: 9,
            onChanged: settings.setGameSpeed,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isFa ? 'درجه سختی' : 'Difficulty'),
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(value: 0, label: Text(isFa ? 'آسان' : 'Easy')),
                  ButtonSegment(value: 1, label: Text(isFa ? 'معمولی' : 'Normal')),
                  ButtonSegment(value: 2, label: Text(isFa ? 'سخت' : 'Hard')),
                ],
                selected: {settings.difficulty},
                onSelectionChanged: (value) => settings.setDifficulty(value.first),
                showSelectedIcon: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIosSettingRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool showDivider,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFa = settings.isPersian;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  _buildAppleIconTile(icon, iconColor),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.55),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: Color(0xFF007AFF),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: isFa ? 0 : 54, right: isFa ? 54 : 0),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
            ),
          ),
      ],
    );
  }

  Widget _buildIosSwitchRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showDivider,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFa = settings.isPersian;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              _buildAppleIconTile(icon, iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: isFa ? 0 : 54, right: isFa ? 54 : 0),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
            ),
          ),
      ],
    );
  }

  Widget _buildAppleIconTile(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildApplePillChip(
    BuildContext context, {
    required ParticleEffectType type,
    required String title,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = settings.particleType == type;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => settings.setParticleType(type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF007AFF)
                : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? accentColor : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? theme.colorScheme.onBackground : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
