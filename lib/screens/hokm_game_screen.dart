import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_settings.dart';
import '../models/hokm_models.dart';
import '../widgets/persian_card_widget.dart';
import '../services/audio_service.dart';

enum GamePhase {
  dealingFirstFive,
  selectingHokm,
  dealingRemaining,
  playingTrick,
  evaluatingTrick,
  roundFinished,
  matchFinished,
}

class HokmGameScreen extends StatefulWidget {
  final AppSettings settings;

  const HokmGameScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<HokmGameScreen> createState() => _HokmGameScreenState();
}

class _HokmGameScreenState extends State<HokmGameScreen>
    with TickerProviderStateMixin {
  // Game State
  GamePhase _phase = GamePhase.dealingFirstFive;
  CardSuit? _hokmSuit;
  int _hakemIndex = 0; // 0: Player (South), 1: East, 2: Partner (North), 3: West
  int _currentTurn = 0;
  int _trickLeader = 0;

  // Hands (Player 0: South, Player 1: East, Player 2: North, Player 3: West)
  final List<List<PlayingCard>> _hands = [[], [], [], []];
  final List<PlayedTrickCard> _currentTrick = [];

  // Trick counts in current round
  int _team1Tricks = 0; // Team 1: Player (0) + Partner (2)
  int _team2Tricks = 0; // Team 2: East (1) + West (3)

  // Overall Match Points (First team to 7 points wins the match)
  int _team1MatchPoints = 0;
  int _team2MatchPoints = 0;

  // UI & Animation Controllers
  PlayingCard? _selectedCard;
  String _statusMessage = '';
  String _announcement = '';
  Timer? _aiTimer;
  Timer? _trickCleanupTimer;

  // Table felt decoration
  final List<PlayingCard> _fullDeck = [];

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  @override
  void dispose() {
    _aiTimer?.cancel();
    _trickCleanupTimer?.cancel();
    super.dispose();
  }

  void _startNewRound() {
    _aiTimer?.cancel();
    _trickCleanupTimer?.cancel();

    final deck = Deck.generateStandardDeck();
    _fullDeck.clear();
    _fullDeck.addAll(deck);

    for (int i = 0; i < 4; i++) {
      _hands[i].clear();
    }
    _currentTrick.clear();
    _team1Tricks = 0;
    _team2Tricks = 0;
    _hokmSuit = null;
    _selectedCard = null;

    setState(() {
      _phase = GamePhase.dealingFirstFive;
      _statusMessage = widget.settings.isPersian
          ? 'دست اول: در حال پخش ۵ کارت اول...'
          : 'Dealing first 5 cards...';
      _announcement = '';
    });

    // Deal 5 cards each
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        for (int p = 0; p < 4; p++) {
          _hands[p] = _fullDeck.sublist(p * 5, (p + 1) * 5);
          _sortHand(_hands[p]);
        }

        // As specified, Player chooses Hokm suit at start (Player is Hakem)
        _hakemIndex = 0;
        _currentTurn = _hakemIndex;
        _trickLeader = _hakemIndex;
        _phase = GamePhase.selectingHokm;
        _statusMessage = widget.settings.isPersian
            ? 'لطفاً خال حکم را تعیین کنید'
            : 'You are the Ruler! Choose the Hokm Suit';
      });
    });
  }

  void _onHokmSuitChosen(CardSuit suit) {
    audioService.playEffect(AudioEffect.card);
    widget.settings.playUiFeedback(isHeavy: true);

    setState(() {
      _hokmSuit = suit;
      _phase = GamePhase.dealingRemaining;
      _statusMessage = widget.settings.isPersian
          ? 'حکم: ${suit.persianName} ${suit.symbol}'
          : 'Hokm Suit: ${suit.englishName} ${suit.symbol}';
      _announcement = widget.settings.isPersian
          ? 'حکم انتخاب شد: ${suit.persianName}'
          : '${suit.englishName} is Trump!';
    });

    // Deal remaining 8 cards each (total 13)
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        for (int p = 0; p < 4; p++) {
          final start = 20 + (p * 8);
          final remaining = _fullDeck.sublist(start, start + 8);
          _hands[p].addAll(remaining);
          _sortHand(_hands[p]);
        }
        _phase = GamePhase.playingTrick;
        _announcement = '';
        _processTurn();
      });
    });
  }

  void _sortHand(List<PlayingCard> hand) {
    hand.sort((a, b) {
      // If Hokm suit is chosen, place Hokm cards first
      if (_hokmSuit != null) {
        if (a.suit == _hokmSuit && b.suit != _hokmSuit) return -1;
        if (b.suit == _hokmSuit && a.suit != _hokmSuit) return 1;
      }
      // Group by suit first, then sort by rank descending (Ace to 2)
      if (a.suit != b.suit) {
        return a.suit.index.compareTo(b.suit.index);
      }
      return b.rank.value.compareTo(a.rank.value);
    });
  }

  void _processTurn() {
    if (_phase != GamePhase.playingTrick) return;

    if (_currentTurn == 0) {
      // Player's turn
      setState(() {
        _statusMessage = widget.settings.isPersian
            ? 'نوبت شماست: کارتی را برای بازی انتخاب کنید'
            : 'Your Turn: Select a card to play';
      });
    } else {
      // AI's Turn (1: East, 2: North, 3: West)
      final names = [
        'You',
        'East (AI)',
        'Teammate (AI)',
        'West (AI)',
      ];
      final faNames = [
        'شما',
        'حریف راست',
        'یار شما',
        'حریف چپ',
      ];

      setState(() {
        _statusMessage = widget.settings.isPersian
            ? 'نوبت ${faNames[_currentTurn]}...'
            : '${names[_currentTurn]} is thinking...';
      });

      _aiTimer?.cancel();
      _aiTimer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _playAiCard(_currentTurn);
      });
    }
  }

  bool _isCardPlayable(PlayingCard card, List<PlayingCard> hand) {
    if (_currentTrick.isEmpty) {
      return true; // Any card can be led
    }

    final leadSuit = _currentTrick.first.card.suit;
    final hasLeadSuit = hand.any((c) => c.suit == leadSuit);

    if (hasLeadSuit) {
      return card.suit == leadSuit; // Must follow suit
    }

    // If player doesn't have lead suit, can cut with Hokm or discard any card
    return true;
  }

  void _playCard(int playerIndex, PlayingCard card) {
    audioService.playEffect(AudioEffect.card);
    if (widget.settings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    widget.settings.playUiFeedback();

    setState(() {
      _hands[playerIndex].remove(card);
      _currentTrick.add(PlayedTrickCard(playerIndex: playerIndex, card: card));
      _selectedCard = null;
    });

    if (_currentTrick.length < 4) {
      // Next player's turn (Clockwise: 0 -> 1 -> 2 -> 3 -> 0)
      _currentTurn = (_currentTurn + 1) % 4;
      _processTurn();
    } else {
      // All 4 players played -> Evaluate Trick
      _phase = GamePhase.evaluatingTrick;
      _evaluateTrick();
    }
  }

  void _playAiCard(int aiIndex) {
    final hand = _hands[aiIndex];
    if (hand.isEmpty) return;

    final playableCards = hand.where((c) => _isCardPlayable(c, hand)).toList();
    if (playableCards.isEmpty) return;

    PlayingCard chosenCard;

    if (_currentTrick.isEmpty) {
      // AI is Leading: Play highest card of a non-trump suit, or Ace
      final aces = playableCards.where((c) => c.rank == CardRank.ace).toList();
      if (aces.isNotEmpty) {
        chosenCard = aces.first;
      } else {
        // Play highest card of strongest suit
        chosenCard = playableCards.first;
      }
    } else {
      final leadSuit = _currentTrick.first.card.suit;
      final sameSuitCards = playableCards.where((c) => c.suit == leadSuit).toList();

      if (sameSuitCards.isNotEmpty) {
        // Must follow suit: try to win with highest or throw lowest
        sameSuitCards.sort((a, b) => b.rank.value.compareTo(a.rank.value));
        chosenCard = sameSuitCards.first;
      } else {
        // Out of suit: check if partner is already winning
        final bestSoFar = _getBestTrickCardSoFar();
        final isPartnerWinning = (aiIndex % 2) == (bestSoFar.playerIndex % 2);

        if (!isPartnerWinning) {
          // Cut with Hokm if available
          final trumps = playableCards.where((c) => c.suit == _hokmSuit).toList();
          if (trumps.isNotEmpty) {
            trumps.sort((a, b) => a.rank.value.compareTo(b.rank.value));
            chosenCard = trumps.first; // Cut with lowest winning trump
          } else {
            // Discard lowest non-Hokm card
            playableCards.sort((a, b) => a.rank.value.compareTo(b.rank.value));
            chosenCard = playableCards.first;
          }
        } else {
          // Partner is winning: discard lowest card
          playableCards.sort((a, b) => a.rank.value.compareTo(b.rank.value));
          chosenCard = playableCards.first;
        }
      }
    }

    _playCard(aiIndex, chosenCard);
  }

  PlayedTrickCard _getBestTrickCardSoFar() {
    PlayedTrickCard best = _currentTrick.first;
    final leadSuit = _currentTrick.first.card.suit;

    for (int i = 1; i < _currentTrick.length; i++) {
      final current = _currentTrick[i];
      if (current.card.suit == _hokmSuit) {
        if (best.card.suit != _hokmSuit || current.card.rank.value > best.card.rank.value) {
          best = current;
        }
      } else if (current.card.suit == leadSuit && best.card.suit != _hokmSuit) {
        if (current.card.rank.value > best.card.rank.value) {
          best = current;
        }
      }
    }
    return best;
  }

  void _evaluateTrick() {
    final winningTrickCard = _getBestTrickCardSoFar();
    final winnerIndex = winningTrickCard.playerIndex;
    final isTeam1Winner = (winnerIndex == 0 || winnerIndex == 2);

    final winnerNames = ['You', 'East', 'Partner', 'West'];
    final winnerFa = ['شما', 'حریف راست', 'یار شما', 'حریف چپ'];

    setState(() {
      if (isTeam1Winner) {
        _team1Tricks++;
      } else {
        _team2Tricks++;
      }

      _announcement = widget.settings.isPersian
          ? 'دست به نفع ${winnerFa[winnerIndex]}'
          : 'Trick won by ${winnerNames[winnerIndex]}';
      _statusMessage = _announcement;
    });

    _trickCleanupTimer?.cancel();
    _trickCleanupTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;

      setState(() {
        _currentTrick.clear();
        _announcement = '';
      });

      // Check if any team has won 7 tricks
      if (_team1Tricks == 7 || _team2Tricks == 7) {
        _handleRoundVictory(_team1Tricks == 7);
      } else {
        // Next trick lead is the winner
        _trickLeader = winnerIndex;
        _currentTurn = winnerIndex;
        _phase = GamePhase.playingTrick;
        _processTurn();
      }
    });
  }

  void _handleRoundVictory(bool isTeam1) {
    _phase = GamePhase.roundFinished;

    int pointsEarned = 1;
    String victoryTitle = '';

    if (isTeam1) {
      if (_team2Tricks == 0) {
        // Kot (7-0)
        pointsEarned = (_hakemIndex == 1 || _hakemIndex == 3) ? 3 : 2; // Hakem Kot = 3 pts
        victoryTitle = (_hakemIndex == 1 || _hakemIndex == 3)
            ? (widget.settings.isPersian ? 'حاکم کوت! (۳ امتیاز)' : 'HAKEM KOT! (3 Points)')
            : (widget.settings.isPersian ? 'کوت! (۲ امتیاز)' : 'KOT! (2 Points)');
      } else {
        victoryTitle = widget.settings.isPersian ? 'دست به نفع تیم شما!' : 'Your Team Won the Round!';
      }
      _team1MatchPoints += pointsEarned;
    } else {
      if (_team1Tricks == 0) {
        pointsEarned = (_hakemIndex == 0 || _hakemIndex == 2) ? 3 : 2;
        victoryTitle = widget.settings.isPersian ? 'حریف شما را کوت کرد!' : 'Opponents Kot You!';
      } else {
        victoryTitle = widget.settings.isPersian ? 'دست به نفع حریف!' : 'Opponents Won the Round!';
      }
      _team2MatchPoints += pointsEarned;
    }
    widget.settings.saveGameRecord('hokm:$_team1MatchPoints-$_team2MatchPoints');

    setState(() {
      _announcement = victoryTitle;
      if (_team1MatchPoints >= 7 || _team2MatchPoints >= 7) {
        _phase = GamePhase.matchFinished;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFa = widget.settings.isPersian;

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0F1D),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.style_rounded, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 8),
              Text(
                isFa ? 'بازی پاسور حکم' : 'Hokm Card Game',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            // Hokm Suit Badge in AppBar
            if (_hokmSuit != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                ),
                child: Row(
                  children: [
                    Text(
                      _hokmSuit!.symbol,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(_hokmSuit!.colorHex),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isFa ? _hokmSuit!.persianName : _hokmSuit!.englishName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            // 1. Luxury Felt Table Layout
            _buildFeltGameTable(context),

            // 2. Hokm Suit Selection Modal Overlay
            if (_phase == GamePhase.selectingHokm)
              _buildHokmSelectionOverlay(context),

            // 3. Round / Match Victory Overlay
            if (_phase == GamePhase.roundFinished || _phase == GamePhase.matchFinished)
              _buildRoundVictoryOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeltGameTable(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF071A2B), Color(0xFF0B3D3A), Color(0xFF071A2B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
      children: [
        // Score Header Bar
        _buildScoreHeader(),

        // Dynamic Felt Card Arena
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(0, 0),
                radius: 1.0,
                colors: [
                  Color(0xFF0F5132), // Classic Persian Emerald Green Felt
                  Color(0xFF062C1B),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Persian subtle center emblem
                Center(
                  child: Opacity(
                    opacity: 0.08,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD700), width: 4),
                      ),
                      child: const Center(
                        child: Icon(Icons.star_rounded, size: 160, color: Color(0xFFFFD700)),
                      ),
                    ),
                  ),
                ),

                // North (Teammate AI)
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: _buildOpponentZone(
                    playerIndex: 2,
                    name: widget.settings.isPersian ? 'یار شما (شمال)' : 'Partner (North)',
                    cardCount: _hands[2].length,
                    isCurrentTurn: _currentTurn == 2,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // West (Opponent Left AI)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildSideOpponentZone(
                      playerIndex: 3,
                      name: widget.settings.isPersian ? 'حریف چپ' : 'West AI',
                      cardCount: _hands[3].length,
                      isCurrentTurn: _currentTurn == 3,
                    ),
                  ),
                ),

                // East (Opponent Right AI)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildSideOpponentZone(
                      playerIndex: 1,
                      name: widget.settings.isPersian ? 'حریف راست' : 'East AI',
                      cardCount: _hands[1].length,
                      isCurrentTurn: _currentTurn == 1,
                    ),
                  ),
                ),

                // Center Trick Field
                Center(
                  child: _buildCenterTrickCards(),
                ),

                // Announcement Banner
                if (_announcement.isNotEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.3),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Text(
                        _announcement,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Bottom: Status message & Player Hand (South)
        _buildPlayerHandZone(),
      ],
      ),
    );
  }

  Widget _buildScoreHeader() {
    final isFa = widget.settings.isPersian;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF0D1527),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Team 1 (You & Partner)
          _buildScoreBadge(
            title: isFa ? 'تیم شما' : 'Your Team',
            tricks: _team1Tricks,
            matchPoints: _team1MatchPoints,
            color: const Color(0xFF00E5FF),
          ),

          // Match Goal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isFa ? 'هدف: ۷ دست' : 'First to 7 Tricks',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFD700),
              ),
            ),
          ),

          // Team 2 (East & West)
          _buildScoreBadge(
            title: isFa ? 'تیم حریف' : 'Opponents',
            tricks: _team2Tricks,
            matchPoints: _team2MatchPoints,
            color: const Color(0xFFFF007F),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge({
    required String title,
    required int tricks,
    required int matchPoints,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            Row(
              children: [
                Text(
                  '$tricks/7',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '($matchPoints pt)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpponentZone({
    required int playerIndex,
    required String name,
    required int cardCount,
    required bool isCurrentTurn,
    required Alignment alignment,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isCurrentTurn
                ? const Color(0xFFFFD700).withOpacity(0.25)
                : Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentTurn ? const Color(0xFFFFD700) : Colors.white24,
              width: isCurrentTurn ? 1.5 : 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentTurn)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.play_arrow_rounded, color: Color(0xFFFFD700), size: 14),
                ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.w500,
                  color: isCurrentTurn ? const Color(0xFFFFD700) : Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Mini card backs representation
        SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              math.min(cardCount, 8),
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: const PersianCardWidget(
                  isFaceUp: false,
                  width: 22,
                  height: 34,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideOpponentZone({
    required int playerIndex,
    required String name,
    required int cardCount,
    required bool isCurrentTurn,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotatedBox(
          quarterTurns: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrentTurn
                  ? const Color(0xFFFFD700).withOpacity(0.25)
                  : Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentTurn ? const Color(0xFFFFD700) : Colors.white24,
              ),
            ),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.w500,
                color: isCurrentTurn ? const Color(0xFFFFD700) : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$cardCount',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildCenterTrickCards() {
    // 4 positions: South (bottom), East (right), North (top), West (left)
    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: _currentTrick.map((ptc) {
          Offset offset = Offset.zero;
          switch (ptc.playerIndex) {
            case 0: // South (Player)
              offset = const Offset(0, 32);
              break;
            case 1: // East
              offset = const Offset(32, 0);
              break;
            case 2: // North (Partner)
              offset = const Offset(0, -32);
              break;
            case 3: // West
              offset = const Offset(-32, 0);
              break;
          }

          return Transform.translate(
            offset: offset,
            child: PersianCardWidget(
              card: ptc.card,
              width: 54,
              height: 80,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlayerHandZone() {
    final isFa = widget.settings.isPersian;
    final myHand = _hands[0];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFFFD700).withOpacity(0.35),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Turn status indicator & Quick Play Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentTurn == 0 ? const Color(0xFFFFD700) : Colors.white38,
                          boxShadow: _currentTurn == 0
                              ? [
                                  const BoxShadow(
                                    color: Color(0xFFFFD700),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _statusMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _currentTurn == 0 ? const Color(0xFFFFD700) : Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentTurn == 0 && _selectedCard != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      minimumSize: const Size(60, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.touch_app_rounded, size: 15),
                    onPressed: () => _playCard(0, _selectedCard!),
                    label: Text(
                      isFa ? 'انداختن کارت' : 'Play Card',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Adaptive Fanned Card Hand that never overflows screen
          if (myHand.isEmpty)
            SizedBox(
              height: 104,
              child: Center(
                child: Text(
                  isFa ? 'دستی برای بازی نمانده است' : 'No cards in hand',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            )
          else
            SizedBox(
              height: 108,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final count = myHand.length;

                  // Adaptive card width calculated to fit all cards
                  final cardWidth = (availableWidth / (count < 5 ? 4.5 : (count < 9 ? 6.5 : 8.2)))
                      .clamp(44.0, 62.0);
                  final cardHeight = cardWidth * 1.45;

                  double step = 0;
                  double startX = 0;

                  if (count == 1) {
                    startX = (availableWidth - cardWidth) / 2;
                  } else {
                    final naturalWidth = count * (cardWidth + 4);
                    if (naturalWidth <= availableWidth) {
                      // Cards fit with comfortable gap
                      final spacing = math.min(6.0, (availableWidth - (count * cardWidth)) / (count - 1));
                      step = cardWidth + spacing;
                      final totalSpan = (count - 1) * step + cardWidth;
                      startX = (availableWidth - totalSpan) / 2;
                    } else {
                      // Smooth overlapping fan guaranteed to fit 100% inside screen width
                      step = (availableWidth - cardWidth) / (count - 1);
                      startX = 0;
                    }
                  }

                  // Force LTR direction so card indices on top-left of each card remain visible as cards fan
                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: List.generate(count, (index) {
                        final card = myHand[index];
                        final isPlayable = (_currentTurn == 0) && _isCardPlayable(card, myHand);
                        final isSelected = _selectedCard == card;

                        final posX = startX + (index * step);

                        return Positioned(
                          left: posX,
                          bottom: 0,
                          child: PersianCardWidget(
                            card: card,
                            width: cardWidth,
                            height: cardHeight,
                            isPlayable: isPlayable,
                            isSelected: isSelected,
                            onTap: () {
                              if (_currentTurn == 0 && isPlayable) {
                                setState(() {
                                  if (_selectedCard == card) {
                                    _playCard(0, card);
                                  } else {
                                    _selectedCard = card;
                                  }
                                });
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHokmSelectionOverlay(BuildContext context) {
    final isFa = widget.settings.isPersian;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ruler Crown Badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 40,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                isFa ? 'شما حاکم هستید!' : 'You Are The Hakem (Ruler)!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isFa
                    ? 'بر اساس ۵ کارت نخست، خال حکم را برگزینید:'
                    : 'Choose the Hokm Suit based on your first 5 cards:',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 24),

              // Suit Choice Buttons
              Wrap(
                spacing: 14,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: CardSuit.values.map((suit) {
                  return InkWell(
                    onTap: () => _onHokmSuitChosen(suit),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 130,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            suit.symbol,
                            style: TextStyle(
                              fontSize: 34,
                              color: Color(suit.colorHex),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isFa ? suit.persianName : suit.englishName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Preview of player's initial 5 cards
              Text(
                isFa ? 'کارت‌های شما:' : 'Your 5 Initial Cards:',
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _hands[0].map((c) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: PersianCardWidget(
                        card: c,
                        width: 48,
                        height: 72,
                        isPlayable: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundVictoryOverlay(BuildContext context) {
    final isFa = widget.settings.isPersian;
    final isMatchOver = _phase == GamePhase.matchFinished;
    final isTeam1Winner = isMatchOver ? (_team1MatchPoints >= 7) : (_team1Tricks >= 7);

    return Container(
      color: Colors.black.withOpacity(0.88),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isTeam1Winner
                        ? [const Color(0xFF00E5FF), const Color(0xFF00E676)]
                        : [const Color(0xFFFF007F), const Color(0xFFFF5722)],
                  ),
                ),
                child: Icon(
                  isTeam1Winner ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                isMatchOver
                    ? (isTeam1Winner
                        ? (isFa ? 'پیروزی کامل در مسابقه!' : 'MATCH VICTORY!')
                        : (isFa ? 'شکست در مسابقه!' : 'MATCH DEFEAT!'))
                    : (isTeam1Winner
                        ? (isFa ? 'پیروزی در این دست!' : 'ROUND WON!')
                        : (isFa ? 'شکست در این دست!' : 'ROUND LOST!')),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isTeam1Winner ? const Color(0xFF00E5FF) : const Color(0xFFFF007F),
                ),
              ),
              const SizedBox(height: 12),

              // Score Table
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isFa ? 'دست‌های تیم شما' : 'Your Team Tricks', style: const TextStyle(color: Colors.white70)),
                        Text('$_team1Tricks / 7', style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isFa ? 'دست‌های تیم حریف' : 'Opponent Tricks', style: const TextStyle(color: Colors.white70)),
                        Text('$_team2Tricks / 7', style: const TextStyle(color: Color(0xFFFF007F), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isFa ? 'امتیاز مسابقه (تیم شما)' : 'Match Points (You)', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                        Text('$_team1MatchPoints - $_team2MatchPoints', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (isMatchOver) {
                        _team1MatchPoints = 0;
                        _team2MatchPoints = 0;
                      }
                      _startNewRound();
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      isMatchOver
                          ? (isFa ? 'شروع مسابقه جدید' : 'NEW MATCH')
                          : (isFa ? 'دست بعدی' : 'NEXT ROUND'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home_rounded),
                    label: Text(isFa ? 'خروج به منو' : 'HOME'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
