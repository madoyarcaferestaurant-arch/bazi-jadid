import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_themes.dart';
import '../services/audio_service.dart';

enum AppLanguage {
  english,
  persian,
}

enum ParticleEffectType {
  fireworks('Fireworks', 'آتش‌بازی', Icons.flare_rounded),
  snow('Falling Snow', 'بارش برف', Icons.ac_unit_rounded),
  random('Surprise Mix', 'ترکیب شگفت‌انگیز', Icons.auto_awesome_rounded);

  final String englishName;
  final String persianName;
  final IconData icon;

  const ParticleEffectType(this.englishName, this.persianName, this.icon);
}

class AppSettings extends ChangeNotifier {
  AppThemeType _themeType = AppThemeType.neonDark;
  AppLanguage _language = AppLanguage.persian;
  bool _touchMeParticles = true;
  ParticleEffectType _particleType = ParticleEffectType.fireworks;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _hapticEnabled = true;
  double _gameSpeed = 1.0;
  int _difficulty = 1;
  final List<String> _gameRecords = [];

  AppSettings() {
    _load();
  }

  AppThemeType get themeType => _themeType;
  AppLanguage get language => _language;
  bool get touchMeParticles => _touchMeParticles;
  ParticleEffectType get particleType => _particleType;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get hapticEnabled => _hapticEnabled;
  double get gameSpeed => _gameSpeed;
  int get difficulty => _difficulty;
  List<String> get gameRecords => List.unmodifiable(_gameRecords);

  bool get isPersian => _language == AppLanguage.persian;
  bool get isRtl => _language == AppLanguage.persian;

  void setTheme(AppThemeType theme) {
    _themeType = theme;
    _save();
    playUiFeedback();
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    _language = lang;
    _save();
    playUiFeedback();
    notifyListeners();
  }

  void setTouchMeParticles(bool val) {
    _touchMeParticles = val;
    _save();
    playUiFeedback();
    notifyListeners();
  }

  void setParticleType(ParticleEffectType type) {
    _particleType = type;
    _save();
    playUiFeedback();
    notifyListeners();
  }

  void setSoundEnabled(bool val) {
    _soundEnabled = val;
    _save();
    audioService.setSoundEnabled(val);
    playUiFeedback();
    notifyListeners();
  }

  void setMusicEnabled(bool val) {
    _musicEnabled = val;
    _save();
    audioService.setMusicEnabled(val);
    playUiFeedback();
    notifyListeners();
  }

  void setHapticEnabled(bool val) {
    _hapticEnabled = val;
    _save();
    playUiFeedback();
    notifyListeners();
  }

  /// Triggers sound / haptic feedback based on current settings
  void playUiFeedback({bool isHeavy = false}) {
    if (_soundEnabled) {
      audioService.playEffect(AudioEffect.click);
      SystemSound.play(SystemSoundType.click);
    }
    if (_hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void setGameSpeed(double value) {
    _gameSpeed = value.clamp(0.7, 1.6);
    _save();
    notifyListeners();
  }

  void setDifficulty(int value) {
    _difficulty = value.clamp(0, 2);
    _save();
    notifyListeners();
  }

  void saveGameRecord(String record) {
    _gameRecords.insert(0, record);
    if (_gameRecords.length > 20) _gameRecords.removeLast();
    _save();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeType = AppThemeType.values[prefs.getInt('themeType') ?? 0];
    _language = AppLanguage.values[prefs.getInt('language') ?? AppLanguage.persian.index];
    _touchMeParticles = prefs.getBool('touchMeParticles') ?? true;
    _particleType = ParticleEffectType.values[prefs.getInt('particleType') ?? 0];
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    _hapticEnabled = prefs.getBool('hapticEnabled') ?? true;
    _gameSpeed = prefs.getDouble('gameSpeed') ?? 1.0;
    _difficulty = prefs.getInt('difficulty') ?? 1;
    _gameRecords..clear()..addAll(prefs.getStringList('gameRecords') ?? const []);
    audioService
      ..setSoundEnabled(_soundEnabled)
      ..setMusicEnabled(_musicEnabled);
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeType', _themeType.index);
    await prefs.setInt('language', _language.index);
    await prefs.setBool('touchMeParticles', _touchMeParticles);
    await prefs.setInt('particleType', _particleType.index);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    await prefs.setBool('hapticEnabled', _hapticEnabled);
    await prefs.setDouble('gameSpeed', _gameSpeed);
    await prefs.setInt('difficulty', _difficulty);
    await prefs.setStringList('gameRecords', _gameRecords);
  }

  String tr(String key) {
    final Map<String, Map<String, String>> localizedValues = {
      'app_title': {
        'en': 'Madoyar App',
        'fa': 'اپلیکیشن مادویار',
      },
      'welcome_badge': {
        'en': 'WELCOME!',
        'fa': 'خوش آمدید!',
      },
      'welcome_title': {
        'en': 'Pick a game and jump into action!',
        'fa': 'انتخاب کنید و لذت ببرید!',
      },
      'welcome_sub': {
        'en': 'Classic rules & fast reflexes',
        'fa': 'بازی‌های جذاب و نوستالژیک',
      },
      'two_sparks': {
        'en': 'Two Sparks: Pulse Mode',
        'fa': 'دو جرقه: حالت پالس',
      },
      'two_sparks_sub': {
        'en': 'Reflex & rhythm pulse mini-game',
        'fa': 'مینی‌گیم واکنشی سریع و ریتمیک',
      },
      'hokm_game': {
        'en': 'Hokm Card Game',
        'fa': 'بازی پاسور حکم',
      },
      'hokm_sub': {
        'en': 'Classic Persian 4-player trick-taking game',
        'fa': 'بازی اصیل و سنتی ۴ نفره حکم',
      },
      'about_us': {
        'en': 'About Us',
        'fa': 'درباره ما',
      },
      'about_title': {
        'en': 'About Madoyar Café & Restaurant',
        'fa': 'درباره کافه و رستوران مادویار',
      },
      'about_us_sub': {
        'en': 'Location, contact & restaurant info',
        'fa': 'اطلاعات کافه، آدرس و تماس',
      },
      'about_desc': {
        'en': 'Madoyar Café & Restaurant offers a warm, cozy ambience blending gourmet drinks, delicious food, and fun interactive games in Mehrshahr, Karaj.',
        'fa': 'کافه و رستوران مادویار، محیطی آرام با منوی غذایی و نوشیدنی‌های لذیذ در مهرشهر کرج.',
      },
      'settings': {
        'en': 'Settings',
        'fa': 'تنظیمات',
      },
      'settings_sub': {
        'en': 'Themes, language, audio & particles',
        'fa': 'تم‌ها، زبان، صدا و ذرات معلق',
      },
      'address_title': {
        'en': 'Address',
        'fa': 'آدرس',
      },
      'address_val': {
        'en': 'Mehrshahr, Eram Boulevard, Street 217',
        'fa': 'مهرشهر، بلوار ارم، خیابان ۲۱۷',
      },
      'phone_title': {
        'en': 'Phone',
        'fa': 'تلفن تماس',
      },
      'phone_val': {
        'en': '09039303575',
        'fa': '09039303575',
      },
      'theme_section': {
        'en': 'Theme Selection',
        'fa': 'انتخاب پوسته و تم',
      },
      'theme_neon_dark': {
        'en': 'Neon Dark',
        'fa': 'نئون تاریک',
      },
      'theme_neon_light': {
        'en': 'Neon Light',
        'fa': 'نئون روشن',
      },
      'theme_classic_minimal': {
        'en': 'Classic Minimal',
        'fa': 'کلاسیک مینیمال',
      },
      'theme_warm_cold': {
        'en': 'Warm & Cold Dual',
        'fa': 'دوگانه گرم و سرد',
      },
      'lang_section': {
        'en': 'Language',
        'fa': 'زبان',
      },
      'effects_section': {
        'en': 'Gameplay & Effects',
        'fa': 'افکت‌ها و جلوه‌های صوتی',
      },
      'touch_me': {
        'en': 'Touch Me!',
        'fa': 'لمسم کن!',
      },
      'touch_me_sub': {
        'en': 'Spawns fireworks or falling snow anywhere you tap',
        'fa': 'نمایش آتش‌بازی یا بارش برف با لمس هر نقطه از صفحه',
      },
      'particle_style': {
        'en': 'Particle Effect Style',
        'fa': 'حالت افکت ذرات',
      },
      'particle_fireworks': {
        'en': 'Fireworks Burst',
        'fa': 'انفجار آتش‌بازی',
      },
      'particle_snow': {
        'en': 'Falling Snow',
        'fa': 'بارش برف رویایی',
      },
      'particle_mix': {
        'en': 'Surprise Mix',
        'fa': 'ترکیب شگفت‌انگیز',
      },
      'particle_test_prompt': {
        'en': 'Tap anywhere to experience the magic particles!',
        'fa': 'برای مشاهده جادوی ذرات، هر جای صفحه را لمس کنید!',
      },
      'sound_effects': {
        'en': 'Sound Effects',
        'fa': 'افکت‌های صوتی',
      },
      'sound_sub': {
        'en': 'Audio feedback on UI clicks and taps',
        'fa': 'پخش صدای کلیک هنگام لمس دکمه‌ها',
      },
      'music': {
        'en': 'Music',
        'fa': 'موسیقی متن',
      },
      'music_sub': {
        'en': 'Background music during gameplay',
        'fa': 'موسیقی زمینه در طول بازی',
      },
      'haptics': {
        'en': 'Haptic Feedback',
        'fa': 'لرزش و بازخورد لمسی',
      },
      'haptics_sub': {
        'en': 'Tactile vibration when interacting',
        'fa': 'لرزش خفیف هنگام تعامل با دکمه‌ها',
      },
      'back': {
        'en': 'Back',
        'fa': 'بازگشت',
      },
    };

    final langCode = isPersian ? 'fa' : 'en';
    return localizedValues[key]?[langCode] ?? key;
  }
}
