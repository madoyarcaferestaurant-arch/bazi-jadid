package com.example.models

import androidx.compose.ui.graphics.Color

enum class CardSuit(
    val englishName: String,
    val persianName: String,
    val symbol: String,
    val defaultColor: Color,
    val isRed: Boolean,
) {
    SPADES("Spades", "پیک", "♠", Color(0xFF1E293B), false),
    HEARTS("Hearts", "دل", "♥", Color(0xFFE11D48), true),
    CLUBS("Clubs", "گشنیز (خاج)", "♣", Color(0xFF0F172A), false),
    DIAMONDS("Diamonds", "خشت", "♦", Color(0xFFEA580C), true);
}

enum class CardRank(
    val value: Int,
    val symbol: String,
    val nameEn: String,
    val nameFa: String,
) {
    TWO(2, "2", "2", "۲"),
    THREE(3, "3", "3", "۳"),
    FOUR(4, "4", "4", "۴"),
    FIVE(5, "5", "5", "۵"),
    SIX(6, "6", "6", "۶"),
    SEVEN(7, "7", "7", "۷"),
    EIGHT(8, "8", "8", "۸"),
    NINE(9, "9", "9", "۹"),
    TEN(10, "10", "10", "۱۰"),
    JACK(11, "J", "Jack", "سرباز"),
    QUEEN(12, "Q", "Queen", "بی‌بی"),
    KING(13, "K", "King", "شاه"),
    ACE(14, "A", "Ace", "تک");
}

data class PlayingCard(
    val suit: CardSuit,
    val rank: CardRank,
    val id: String = "${suit.name}_${rank.name}",
) {
    val displayShort: String get() = "${rank.symbol}${suit.symbol}"
}

enum class PlayerSeat(val id: Int, val nameEn: String, val nameFa: String, val isTeamUs: Boolean) {
    USER(0, "You", "شما", true),
    RIGHT(1, "Rival Right", "رقیب راست", false),
    PARTNER(2, "Partner", "یار شما", true),
    LEFT(3, "Rival Left", "رقیب چپ", false);

    fun next(): PlayerSeat = when (this) {
        USER -> RIGHT
        RIGHT -> PARTNER
        PARTNER -> LEFT
        LEFT -> USER
    }
}

data class PlayedCard(
    val player: PlayerSeat,
    val card: PlayingCard,
)

enum class HokmGameState {
    SELECTING_HOKM,
    PLAYING,
    TRICK_FINISHED,
    ROUND_FINISHED,
    MATCH_FINISHED,
}
