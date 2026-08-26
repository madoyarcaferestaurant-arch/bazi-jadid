import 'package:audioplayers/audioplayers.dart';

enum AudioEffect { click, jump, death, card, dice, laser, explosion, powerUp }

final audioService = AppAudioService();

class AppAudioService {
  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'madoyar-music');
  final AudioPlayer _effectPlayer = AudioPlayer(playerId: 'madoyar-effects');
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _musicStarted = false;

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _effectPlayer.setVolume(enabled ? 0.8 : 0);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    if (enabled) {
      await startMusic();
    } else {
      await _musicPlayer.stop();
    }
  }

  Future<void> startMusic({String track = 'audio/music.wav'}) async {
    if (!_musicEnabled || _musicStarted) return;
    _musicStarted = true;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.22);
    await _musicPlayer.play(AssetSource(track));
  }

  Future<void> stopMusic() async {
    _musicStarted = false;
    await _musicPlayer.stop();
  }

  Future<void> playEffect(AudioEffect effect) async {
    if (!_soundEnabled) return;
    final file = switch (effect) {
      AudioEffect.click => 'audio/click.wav',
      AudioEffect.jump => 'audio/jump.wav',
      AudioEffect.death => 'audio/death.wav',
      AudioEffect.card => 'audio/click.wav',
      AudioEffect.dice => 'audio/click.wav',
      AudioEffect.laser => 'audio/jump.wav',
      AudioEffect.explosion => 'audio/death.wav',
      AudioEffect.powerUp => 'audio/jump.wav',
    };
    await _effectPlayer.play(AssetSource(file), volume: 0.8);
  }
}