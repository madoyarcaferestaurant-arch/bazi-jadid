import 'dart:math' as math;

enum CardSuit {
  spades('Spades', 'پیک', '♠', 0xFF1E293B, false),
  hearts('Hearts', 'دل', '♥', 0xFFE11D48, true),
  diamonds('Diamonds', 'خشت', '♦', 0xFFE11D48, true),
  clubs('Clubs', 'گشنیز', '♣', 0xFF1E293B, false);

  final String englishName;
  final String persianName;
  final String symbol;
  final int colorHex;
  final bool isRed;

  const CardSuit(
    this.englishName,
    this.persianName,
    this.symbol,
    this.colorHex,
    this.isRed,
  );
}

enum CardRank {
  two(2, '2', '۲'),
  three(3, '3', '۳'),
  four(4, '4', '۴'),
  five(5, '5', '۵'),
  six(6, '6', '۶'),
  seven(7, '7', '۷'),
  eight(8, '8', '۸'),
  nine(9, '9', '۹'),
  ten(10, '10', '۱۰'),
  jack(11, 'J', 'سرباز'),
  queen(12, 'Q', 'بی‌بی'),
  king(13, 'K', 'شاه'),
  ace(14, 'A', 'تک');

  final int value; // 2 to 14 (Ace is highest in Hokm)
  final String label;
  final String persianLabel;

  const CardRank(this.value, this.label, this.persianLabel);
}

class PlayingCard {
  final CardSuit suit;
  final CardRank rank;
  final String id;

  PlayingCard({required this.suit, required this.rank})
      : id = '${suit.name}_${rank.name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

  @override
  String toString() => '${rank.label}${suit.symbol}';
}

class PlayedTrickCard {
  final int playerIndex; // 0: Player (South), 1: East, 2: Partner (North), 3: West
  final PlayingCard card;

  PlayedTrickCard({required this.playerIndex, required this.card});
}

class Deck {
  static List<PlayingCard> generateStandardDeck() {
    final List<PlayingCard> cards = [];
    for (final suit in CardSuit.values) {
      for (final rank in CardRank.values) {
        cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }
    cards.shuffle(math.Random());
    return cards;
  }
}
