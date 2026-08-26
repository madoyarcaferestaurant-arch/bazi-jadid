import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:madoyar_app/embedded/treasure_hunt/domain/core/providers.dart';
import 'package:madoyar_app/embedded/treasure_hunt/main.dart';
import 'package:madoyar_app/embedded/treasure_hunt/presentation/components/volume_slider.dart';
import 'package:madoyar_app/embedded/treasure_hunt/presentation/overlays/overlay_container.dart';

class AudioSettingsOverlay extends ConsumerWidget {
  final void Function() onClose;

  const AudioSettingsOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioSettings = ref.watch(Providers.audioSettingsProvider);
    final audioSettingsNotifier = ref.read(
      Providers.audioSettingsProvider.notifier,
    );

    return OverlayContainer(
      title: 'Audio Settings',
      onClose: onClose,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            VolumeSlider(
              label: 'Music Volume',
              value: audioSettings.musicVolume,
              onChanged: (value) => audioSettingsNotifier.setMusicVolume(value),
              icon: Icons.music_note,
              isMuted: audioSettings.isMusicMuted,
              onMutePressed: () => audioSettingsNotifier.toggleMusicMute(),
            ),
            const Gap(16.0),
            VolumeSlider(
              label: 'Sound Effects',
              value: audioSettings.sfxVolume,
              onChanged: (value) => audioSettingsNotifier.setSfxVolume(value),
              icon: Icons.volume_up,
              isMuted: audioSettings.isSfxMuted,
              onMutePressed: () => audioSettingsNotifier.toggleSfxMute(),
            ),
            Spacer(),
            ListTile(
              leading: Icon(
                Platform.isMacOS ? MdiIcons.apple : MdiIcons.android,
                size: 25,
                color: Colors.white,
              ),
              title: Text(
                'v${packageInfo.version}+${packageInfo.buildNumber}',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'For ${Platform.operatingSystem}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
