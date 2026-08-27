import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:madoyar_app/embedded/treasure_hunt/domain/core/models/audio_settings.dart';

class AudioSettingsNotifier extends riverpod.Notifier<AudioSettings> {
  // bool _isMusicInitialized = false;

  @override
  AudioSettings build() => AudioSettings();

  Future<void> initializeMusic(String musicFile) async {
    // TODO (Trey) - Create toggle for playing music
    await FlameAudio.bgm.play(musicFile);

    await FlameAudio.bgm.audioPlayer.setVolume(
      state.isMusicMuted ? 0.0 : state.musicVolume,
    );
  }

  void setMusicVolume(double volume) {
    state = state.copyWith(
      musicVolume: volume,
      lastMusicVolume: volume,
      isMusicMuted: false,
    );

    FlameAudio.bgm.audioPlayer.setVolume(volume);
  }

  void setSfxVolume(double volume) {
    state = state.copyWith(
      sfxVolume: volume,
      lastSfxVolume: volume,
      isSfxMuted: false,
    );
  }

  void toggleMusicMute() {
    final isMuted = !state.isMusicMuted;
    final newVolume = isMuted ? 0.0 : state.lastMusicVolume;

    state = state.copyWith(musicVolume: newVolume, isMusicMuted: isMuted);

    FlameAudio.bgm.audioPlayer.setVolume(newVolume);
  }

  void toggleSfxMute() {
    final isMuted = !state.isSfxMuted;
    final newVolume = isMuted ? 0.0 : state.lastSfxVolume;

    state = state.copyWith(sfxVolume: newVolume, isSfxMuted: isMuted);
  }
}
