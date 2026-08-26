import 'package:flutter/material.dart';
import 'package:gem_game/screens/mode_select_screen.dart';
import '../models/app_settings.dart';

class GemsGameScreen extends StatelessWidget {
  final AppSettings settings;

  const GemsGameScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('جِمز')),
        body: const ModeSelectScreen(),
      ),
    );
  }
}
