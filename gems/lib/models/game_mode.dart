enum GameModeType {
  timed,
  moves,
  target,
  zen,
}

extension GameModeTypeExtension on GameModeType {
  String get displayName {
    switch (this) {
      case GameModeType.timed:
        return 'زمانی';
      case GameModeType.moves:
        return 'حرکت‌ها';
      case GameModeType.target:
        return 'هدف';
      case GameModeType.zen:
        return 'آرامش';
    }
  }

  String get description {
    switch (this) {
      case GameModeType.timed:
        return 'با زمان رقابت کنید و پیش از پایان وقت، بیشترین امتیاز را بگیرید.';
      case GameModeType.moves:
        return 'حرکت‌ها محدودند؛ هر جابه‌جایی را برای بیشترین امتیاز حساب‌شده انجام دهید.';
      case GameModeType.target:
        return 'برای پیشرفت به امتیاز هدف برسید؛ هر مرحله سخت‌تر می‌شود.';
      case GameModeType.zen:
        return 'آرام بازی کنید و تا هر وقت خواستید ادامه دهید؛ بدون فشار و پایان.';
    }
  }

  String get icon {
    switch (this) {
      case GameModeType.timed:
        return '⏱️';
      case GameModeType.moves:
        return '🎯';
      case GameModeType.target:
        return '🏆';
      case GameModeType.zen:
        return '🧘';
    }
  }
}

class GameMode {
  final GameModeType type;
  final int timeSeconds; // For timed mode
  final int maxMoves; // For moves mode
  final int targetScore; // For target mode
  final int level; // For target mode progression

  const GameMode.timed({this.timeSeconds = 90})
      : type = GameModeType.timed,
        maxMoves = 0,
        targetScore = 0,
        level = 0;

  const GameMode.moves({this.maxMoves = 30})
      : type = GameModeType.moves,
        timeSeconds = 0,
        targetScore = 0,
        level = 0;

  // Quadratic ramp: 3000, 5250, 8000, 11250, 15000… One good cascade with
  // combos earns 1000-3000, so level 1 must cost several moves (field
  // report: the old 1000 target fell to a single first move).
  const GameMode.target({this.level = 1})
      : type = GameModeType.target,
        timeSeconds = 0,
        maxMoves = 0,
        targetScore =
            3000 + (level - 1) * 2000 + (level - 1) * (level - 1) * 250;

  const GameMode.zen()
      : type = GameModeType.zen,
        timeSeconds = 0,
        maxMoves = 0,
        targetScore = 0,
        level = 0;

  GameMode nextLevel() {
    if (type == GameModeType.target) {
      return GameMode.target(level: level + 1);
    }
    return this;
  }

  String get leaderboardKey => type.name;
}
