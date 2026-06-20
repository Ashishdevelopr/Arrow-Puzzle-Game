import 'package:audioplayers/audioplayers.dart';

class AudioService {
  bool _soundEnabled = true;

  final AudioPlayer _sfxPlayer = AudioPlayer();

  void setSoundEnabled(bool v) => _soundEnabled = v;
  bool get isSoundEnabled => _soundEnabled;

  Future<void> playPop() async {
    if (!_soundEnabled) return;
    // Placeholder: no actual audio files bundled yet
  }

  Future<void> playThud() async {
    if (!_soundEnabled) return;
  }

  Future<void> playWin() async {
    if (!_soundEnabled) return;
  }

  void dispose() {
    _sfxPlayer.dispose();
  }
}
