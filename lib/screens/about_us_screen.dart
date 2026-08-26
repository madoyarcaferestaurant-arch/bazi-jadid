import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/madoyar_logo.dart';
import '../models/app_settings.dart';

class AboutUsScreen extends StatelessWidget {
  final AppSettings settings;

  const AboutUsScreen({Key? key, required this.settings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const isFa = true;

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'درباره ما',
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Apple Profile / Logo Card
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.12)
                            : Colors.black.withOpacity(0.06),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const MadoyarLogo(
                      size: 68,
                      showText: false,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Brand Name
                Text(
                  'کافه و رستوران مادویار',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: theme.colorScheme.onBackground,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'محیطی صمیمی، بازی‌های فکری و نوشیدنی‌های خاص',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),

                const SizedBox(height: 28),

                // Section Header: Contact Details
                Align(
                  alignment: isFa ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      'اطلاعات تماس و نشانی',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: isFa ? 0.0 : 0.6,
                        color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Inset Grouped Info Box
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
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
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      children: [
                        // Address Row
                        _buildAppleInfoRow(
                          context,
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFFFF3B30),
                          title: 'آدرس',
                          value: 'مهرشهر، بلوار ارم، خیابان ۲۱۷',
                          showDivider: true,
                          actionIcon: Icons.copy_rounded,
                          onAction: () {
                            Clipboard.setData(const ClipboardData(text: 'مهرشهر، بلوار ارم، خیابان ۲۱۷'));
                            settings.playUiFeedback();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('آدرس کپی شد'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                        ),

                        // Phone Row
                        _buildAppleInfoRow(
                          context,
                          icon: Icons.phone_rounded,
                          iconColor: const Color(0xFF34C759),
                          title: 'تلفن تماس',
                          value: '09039303575',
                          showDivider: false,
                          actionIcon: Icons.copy_rounded,
                          onAction: () {
                            Clipboard.setData(const ClipboardData(text: '09039303575'));
                            settings.playUiFeedback();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('شماره تماس کپی شد'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Section Header: About Description
                Align(
                  alignment: isFa ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      'درباره مجموعه',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: isFa ? 0.0 : 0.6,
                        color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // About Description Group Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
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
                  child: Text(
                    'کافه و رستوران مادویار، محیطی آرام با منوی غذایی و نوشیدنی‌های لذیذ در مهرشهر کرج.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      letterSpacing: -0.1,
                      color: theme.colorScheme.onSurface.withOpacity(0.85),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Footer version
                Text(
                  'نسخه ۱.۰.۰ مادویار',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppleInfoRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool showDivider,
    required IconData actionIcon,
    required VoidCallback onAction,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const isFa = true;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Squircle Icon Container
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 14),

              // Title & Value
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(actionIcon, size: 18, color: const Color(0xFF007AFF)),
                tooltip: 'کپی',
                onPressed: onAction,
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: isFa ? 0 : 54.0, right: isFa ? 54.0 : 0),
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
