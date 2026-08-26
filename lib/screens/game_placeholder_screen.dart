import 'package:flutter/material.dart';
import '../models/app_settings.dart';

class GamePlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const GamePlaceholderScreen({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Game Badge Icon
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 54,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 28),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 36),

                // Placeholder container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.construction_rounded, color: theme.colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Text(
                            'Module Placeholder',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.tertiary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Game engine core, graphics shaders, and rules logic will be initialized here in the next update.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
