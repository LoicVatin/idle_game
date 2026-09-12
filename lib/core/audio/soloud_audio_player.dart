import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:idle_game/utils/logger_helper.dart';
import 'package:idle_game/utils/shared_preferences_helper.dart';

class SoLoudAudioPlayer {
  SoLoudAudioPlayer._();

  static const String _audioAssets = "assets/audio/";
  static final String _bgm = "${_audioAssets}bgm.ogg";
  static const double _volume = 0.5;

  static const int _webBootAttempts = 20;
  static const Duration _webBootRetryDelay = Duration(milliseconds: 100);

  static AudioSource? _source;
  static SoundHandle? _handle;
  static AppLifecycleListener? _lifecycleListener;

  static Future<void>? _ready;

  static bool isOn = true;

  static bool _isForeground = true;

  static Future<void> initialize() async {
    appLogger.d("SoLoudAudioPlayer.initialize()");

    isOn = await SharedPreferencesHelper.isBackgroundMusicOn();

    _lifecycleListener = AppLifecycleListener(
      onStateChange: _onLifecycleStateChange,
    );
    _ready = _bootEngine();
  }

  static Future<void> startBgm() async {
    appLogger.d("SoLoudAudioPlayer.startBgm()");

    await _ready;

    final source = _source;
    if (source == null || _handle != null) {
      return;
    }

    try {
      // Start paused so no audio device is needed until the loop is audible.
      final handle = SoLoud.instance.play(
        source,
        volume: _volume,
        looping: true,
        paused: true,
      );
      _handle = handle;
      // Never let a future sound effect evict the music voice.
      SoLoud.instance.setProtectVoice(handle, true);
      _applyPauseState();
    } catch (error, stackTrace) {
      appLogger.e(
        "SoLoudAudioPlayer.startBgm() failed",
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> setBackgroundMusicOn(bool isMusicOn) async {
    isOn = isMusicOn;
    await SharedPreferencesHelper.setBackgroundMusicOn(isMusicOn);
    _applyPauseState();
  }

  static Future<void> _bootEngine() async {
    final attempts = kIsWeb ? _webBootAttempts : 1;

    for (var attempt = 1; attempt <= attempts; attempt++) {
      try {
        await SoLoud.instance.init(sampleRate: 48000);
        _source = await SoLoud.instance.loadAsset(_bgm);
        return;
      } catch (error, stackTrace) {
        if (attempt < attempts) {
          await Future<void>.delayed(_webBootRetryDelay);
          continue;
        }

        appLogger.e(
          "SoLoudAudioPlayer: audio engine unavailable, the game runs muted",
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  static void _onLifecycleStateChange(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    _applyPauseState();
  }

  static void _applyPauseState() {
    final handle = _handle;
    if (handle == null) {
      return;
    }

    try {
      SoLoud.instance.setPause(handle, !(isOn && _isForeground));
    } catch (error, stackTrace) {
      appLogger.e(
        "SoLoudAudioPlayer._applyPauseState() failed",
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> dispose() async {
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    _handle = null;
    _ready = null;

    final source = _source;
    _source = null;
    if (source != null) {
      await SoLoud.instance.disposeSource(source);
    }
    await SoLoud.instance.deinitAsync();
  }
}
