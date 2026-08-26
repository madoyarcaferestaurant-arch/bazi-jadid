package com.example.viewmodels

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.models.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class HokmViewModel : ViewModel() {
    var gameState by mutableStateOf(HokmGameState.SELECTING_HOKM)
    var hakem by mutableStateOf(PlayerSeat.USER)
    var hokmSuit by mutableStateOf<CardSuit?>(null)
    var currentTurn by mutableStateOf(PlayerSeat.USER)
    var leadSuit by mutableStateOf<CardSuit?>(null)

    // Hands for 4 seats
    val userHand = mutableStateListOf<PlayingCard>()
    val rightHand = mutableStateListOf<PlayingCard>()
    val partnerHand = mutableStateListOf<PlayingCard>()
    val leftHand = mutableStateListOf<PlayingCard>()

    // Current Trick on Table
    val currentTrick = mutableStateListOf<PlayedCard>()

    // Trick Counts in Current Round (First to 7 wins round)
    var teamUsTricks by mutableIntStateOf(0)
    var teamThemTricks by mutableIntStateOf(0)

    // Total Match Scores (First to 7 hands wins match)
    var teamUsMatchScore by mutableIntStateOf(0)
    var teamThemMatchScore by mutableIntStateOf(0)

    var statusMessageEn by mutableStateOf("Select Hokm Suit from your first 5 cards!")
    var statusMessageFa by mutableStateOf("خال حکم را از ۵ کارت اولیه خود انتخاب کنید!")
    var lastTrickWinner by mutableStateOf<PlayerSeat?>(null)
    var isThinkingAI by mutableStateOf(false)

    private var fullDeck: MutableList<PlayingCard> = mutableListOf()

    init {
        startNewMatch()
    }

    fun startNewMatch() {
        teamUsMatchScore = 0
        teamThemMatchScore = 0
        hakem = PlayerSeat.USER
        startNewRound()
    }

    fun startNewRound() {
        teamUsTricks = 0
        teamThemTricks = 0
        hokmSuit = null
        leadSuit = null
        currentTrick.clear()
        userHand.clear()
        rightHand.clear()
        partnerHand.clear()
        leftHand.clear()

        // 1. Generate and shuffle standard 52 deck
        fullDeck = mutableListOf()
        for (suit in CardSuit.values()) {
            for (rank in CardRank.values()) {
                fullDeck.add(PlayingCard(suit, rank))
            }
        }
        fullDeck.shuffle()

        // 2. Deal first 5 cards to all players
        for (i in 0 until 5) userHand.add(fullDeck.removeAt(0))
        for (i in 0 until 5) rightHand.add(fullDeck.removeAt(0))
        for (i in 0 until 5) partnerHand.add(fullDeck.removeAt(0))
        for (i in 0 until 5) leftHand.add(fullDeck.removeAt(0))

        sortHand(userHand)

        if (hakem == PlayerSeat.USER) {
            gameState = HokmGameState.SELECTING_HOKM
            statusMessageEn = "Select the Trump Suit (Hokm) from your 5 cards"
            statusMessageFa = "شما حاکم هستید. خال حکم را انتخاب کنید"
        } else {
            // AI chooses Hokm
            gameState = HokmGameState.SELECTING_HOKM
            viewModelScope.launch {
                delay(900)
                val aiHand = when (hakem) {
                    PlayerSeat.RIGHT -> rightHand
                    PlayerSeat.PARTNER -> partnerHand
                    PlayerSeat.LEFT -> leftHand
                    else -> userHand
                }
                val bestSuit = chooseBestHokmSuit(aiHand)
                selectHokmSuit(bestSuit)
            }
        }
    }

    fun selectHokmSuit(suit: CardSuit) {
        hokmSuit = suit

        // Deal remaining 8 cards to each player (total 13 cards)
        for (i in 0 until 8) userHand.add(fullDeck.removeAt(0))
        for (i in 0 until 8) rightHand.add(fullDeck.removeAt(0))
        for (i in 0 until 8) partnerHand.add(fullDeck.removeAt(0))
        for (i in 0 until 8) leftHand.add(fullDeck.removeAt(0))

        sortHand(userHand)
        sortHand(rightHand)
        sortHand(partnerHand)
        sortHand(leftHand)

        gameState = HokmGameState.PLAYING
        currentTurn = hakem
        leadSuit = null
        statusMessageEn = "Hokm is ${suit.englishName} ${suit.symbol}. ${currentTurn.nameEn}'s Turn!"
        statusMessageFa = "خال حکم: ${suit.persianName} ${suit.symbol}. نوبت ${currentTurn.nameFa}"

        if (currentTurn != PlayerSeat.USER) {
            triggerAITurn()
        }
    }

    private fun sortHand(hand: MutableList<PlayingCard>) {
        hand.sortWith(compareBy({ it.suit.ordinal }, { it.rank.value }))
    }

    fun canUserPlayCard(card: PlayingCard): Boolean {
        if (gameState != HokmGameState.PLAYING) return false
        if (currentTurn != PlayerSeat.USER) return false
        if (isThinkingAI) return false

        val curLead = leadSuit ?: return true
        val hasLeadSuit = userHand.any { it.suit == curLead }
        if (hasLeadSuit) {
            return card.suit == curLead
        }
        return true
    }

    fun playUserCard(card: PlayingCard) {
        if (!canUserPlayCard(card)) return

        userHand.remove(card)
        onCardPlayed(PlayerSeat.USER, card)
    }

    private fun onCardPlayed(player: PlayerSeat, card: PlayingCard) {
        if (currentTrick.isEmpty()) {
            leadSuit = card.suit
        }
        currentTrick.add(PlayedCard(player, card))

        if (currentTrick.size < 4) {
            currentTurn = player.next()
            statusMessageEn = "${player.nameEn} played ${card.displayShort}. ${currentTurn.nameEn}'s Turn"
            statusMessageFa = "${player.nameFa} کارت ${card.displayShort} را انداخت. نوبت ${currentTurn.nameFa}"

            if (currentTurn != PlayerSeat.USER) {
                triggerAITurn()
            }
        } else {
            // Trick complete! Evaluate winner
            gameState = HokmGameState.TRICK_FINISHED
            evaluateTrick()
        }
    }

    private fun triggerAITurn() {
        if (isThinkingAI) return
        isThinkingAI = true
        viewModelScope.launch {
            delay(850)
            val aiHand = when (currentTurn) {
                PlayerSeat.RIGHT -> rightHand
                PlayerSeat.PARTNER -> partnerHand
                PlayerSeat.LEFT -> leftHand
                else -> userHand
            }
            if (aiHand.isNotEmpty()) {
                val cardToPlay = chooseAICard(currentTurn, aiHand, leadSuit, hokmSuit!!, currentTrick)
                aiHand.remove(cardToPlay)
                isThinkingAI = false
                onCardPlayed(currentTurn, cardToPlay)
            } else {
                isThinkingAI = false
            }
        }
    }

    private fun evaluateTrick() {
        val hSuit = hokmSuit ?: CardSuit.SPADES
        val lSuit = leadSuit ?: currentTrick.first().card.suit

        var winningPlay = currentTrick.first()

        for (play in currentTrick) {
            val isCurrentWinnerHokm = winningPlay.card.suit == hSuit
            val isCandidateHokm = play.card.suit == hSuit

            if (isCandidateHokm && !isCurrentWinnerHokm) {
                winningPlay = play
            } else if (isCandidateHokm && isCurrentWinnerHokm) {
                if (play.card.rank.value > winningPlay.card.rank.value) {
                    winningPlay = play
                }
            } else if (!isCandidateHokm && !isCurrentWinnerHokm) {
                if (play.card.suit == lSuit && winningPlay.card.suit == lSuit) {
                    if (play.card.rank.value > winningPlay.card.rank.value) {
                        winningPlay = play
                    }
                }
            }
        }

        val winner = winningPlay.player
        lastTrickWinner = winner

        if (winner.isTeamUs) {
            teamUsTricks++
            statusMessageEn = "${winner.nameEn} won the trick!"
            statusMessageFa = "${winner.nameFa} دست را برد!"
        } else {
            teamThemTricks++
            statusMessageEn = "${winner.nameEn} won the trick!"
            statusMessageFa = "${winner.nameFa} دست را برد!"
        }

        viewModelScope.launch {
            delay(1600)
            currentTrick.clear()
            leadSuit = null

            // Check if round won (7 tricks)
            if (teamUsTricks >= 7 || teamThemTricks >= 7) {
                finishRound()
            } else {
                gameState = HokmGameState.PLAYING
                currentTurn = winner
                statusMessageEn = "${winner.nameEn}'s Turn to lead"
                statusMessageFa = "نوبت ${winner.nameFa} برای شروع دست"
                if (currentTurn != PlayerSeat.USER) {
                    triggerAITurn()
                }
            }
        }
    }

    private fun finishRound() {
        val usWon = teamUsTricks >= 7
        val isHakemUs = hakem.isTeamUs

        var pointsWon = 1
        if (usWon) {
            if (teamThemTricks == 0) {
                // Kot!
                pointsWon = if (!isHakemUs) 3 else 2 // Hakem-Kot vs Kot
            }
            teamUsMatchScore += pointsWon
            statusMessageEn = "🎉 Team Us won the round! (+$pointsWon Hand points)"
            statusMessageFa = "🎉 تیم ما دست را برد! (+$pointsWon امتیاز مسابقه)"
            // Hakem stays if won, changes if lost
            if (!isHakemUs) hakem = PlayerSeat.USER
        } else {
            if (teamUsTricks == 0) {
                pointsWon = if (isHakemUs) 3 else 2
            }
            teamThemMatchScore += pointsWon
            statusMessageEn = "Opponents won the round! (+$pointsWon Hand points)"
            statusMessageFa = "حریفان دست را بردند! (+$pointsWon امتیاز مسابقه)"
            if (isHakemUs) hakem = PlayerSeat.RIGHT
        }

        if (teamUsMatchScore >= 7 || teamThemMatchScore >= 7) {
            gameState = HokmGameState.MATCH_FINISHED
            val champion = if (teamUsMatchScore >= 7) "Us (Team 1)" else "Opponents (Team 2)"
            val championFa = if (teamUsMatchScore >= 7) "تیم شما (برنده نهایی)" else "تیم حریفان (برنده نهایی)"
            statusMessageEn = "🏆 Match Finished! Champion: $champion"
            statusMessageFa = "🏆 پایان مسابقه! قهرمان: $championFa"
        } else {
            gameState = HokmGameState.ROUND_FINISHED
        }
    }

    private fun chooseBestHokmSuit(hand: List<PlayingCard>): CardSuit {
        val counts = hand.groupingBy { it.suit }.eachCount()
        return counts.maxByOrNull { it.value }?.key ?: CardSuit.SPADES
    }

    private fun chooseAICard(
        player: PlayerSeat,
        hand: List<PlayingCard>,
        lead: CardSuit?,
        hokm: CardSuit,
        trick: List<PlayedCard>
    ): PlayingCard {
        if (lead == null) {
            // AI leads: Prefer highest non-hokm or high ace/king, else lowest
            val nonHokm = hand.filter { it.suit != hokm }
            val aces = nonHokm.filter { it.rank == CardRank.ACE }
            if (aces.isNotEmpty()) return aces.random()
            val kings = nonHokm.filter { it.rank == CardRank.KING }
            if (kings.isNotEmpty()) return kings.random()
            return hand.maxByOrNull { it.rank.value } ?: hand.random()
        }

        // Must follow lead if possible
        val followCards = hand.filter { it.suit == lead }
        if (followCards.isNotEmpty()) {
            val partnerPlayed = trick.firstOrNull { it.player == player.next().next() }
            val isPartnerWinning = partnerPlayed != null && trick.maxByOrNull { it.card.rank.value } == partnerPlayed
            return if (isPartnerWinning) {
                followCards.minByOrNull { it.rank.value } ?: followCards.first()
            } else {
                followCards.maxByOrNull { it.rank.value } ?: followCards.first()
            }
        }

        // Doesn't have lead suit: Cut with Hokm or discard lowest
        val hokmCards = hand.filter { it.suit == hokm }
        if (hokmCards.isNotEmpty()) {
            return hokmCards.minByOrNull { it.rank.value } ?: hokmCards.first()
        }

        // Discard lowest card
        return hand.minByOrNull { it.rank.value } ?: hand.first()
    }
}
