package com.example.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.models.*
import com.example.ui.components.PersianCardView
import com.example.viewmodels.HokmViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HokmScreen(
    settings: AppSettings,
    onBack: () -> Unit,
    viewModel: HokmViewModel = viewModel()
) {
    val isFa = settings.isRtl
    var selectedCard by remember { mutableStateOf<PlayingCard?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = settings.tr("hokm_title"),
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp
                    )
                },
                navigationIcon = {
                    IconButton(
                        onClick = onBack,
                        modifier = Modifier.testTag("hokm_back_button")
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = settings.tr("back_to_hub")
                        )
                    }
                },
                actions = {
                    IconButton(
                        onClick = { viewModel.startNewMatch() },
                        modifier = Modifier.testTag("hokm_restart_button")
                    ) {
                        Icon(
                            imageVector = Icons.Default.Refresh,
                            contentDescription = settings.tr("restart_game")
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = settings.themeType.surfaceColor,
                    titleContentColor = settings.themeType.onSurfaceColor
                )
            )
        },
        containerColor = settings.themeType.backgroundColor
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            settings.themeType.surfaceColor,
                            settings.themeType.backgroundColor
                        )
                    )
                )
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 12.dp, vertical = 6.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.SpaceBetween
            ) {
                // 1. TOP SCOREBOARD BAR
                ScoreBoardBar(viewModel, settings)

                // 2. PARTNER AREA (TOP)
                PlayerSlot(
                    name = settings.tr("partner"),
                    seat = PlayerSeat.PARTNER,
                    cardsCount = viewModel.partnerHand.size,
                    isHakem = viewModel.hakem == PlayerSeat.PARTNER,
                    isTurn = viewModel.currentTurn == PlayerSeat.PARTNER,
                    accentColor = settings.themeType.primaryColor
                )

                // 3. MIDDLE ARENA: RIVALS & PLAYED CARDS FELT
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Left Rival
                    PlayerSlot(
                        name = settings.tr("opponent_left"),
                        seat = PlayerSeat.LEFT,
                        cardsCount = viewModel.leftHand.size,
                        isHakem = viewModel.hakem == PlayerSeat.LEFT,
                        isTurn = viewModel.currentTurn == PlayerSeat.LEFT,
                        accentColor = settings.themeType.secondaryColor
                    )

                    // Center Table Arena (Played cards in trick)
                    CenterTrickTable(viewModel, settings)

                    // Right Rival
                    PlayerSlot(
                        name = settings.tr("opponent_right"),
                        seat = PlayerSeat.RIGHT,
                        cardsCount = viewModel.rightHand.size,
                        isHakem = viewModel.hakem == PlayerSeat.RIGHT,
                        isTurn = viewModel.currentTurn == PlayerSeat.RIGHT,
                        accentColor = settings.themeType.secondaryColor
                    )
                }

                // 4. STATUS & GAME PROMPT
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = settings.themeType.surfaceColor.copy(alpha = 0.9f),
                    border = BorderStroke(1.dp, settings.themeType.primaryColor.copy(alpha = 0.4f)),
                    modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp)
                ) {
                    Text(
                        text = if (isFa) viewModel.statusMessageFa else viewModel.statusMessageEn,
                        color = settings.themeType.primaryColor,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.SemiBold,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                    )
                }

                // 5. USER HAND (BOTTOM)
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 4.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = "👤 ${settings.tr("your_turn")}",
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (viewModel.currentTurn == PlayerSeat.USER) settings.themeType.primaryColor else Color.Gray
                            )
                            if (viewModel.hakem == PlayerSeat.USER) {
                                Spacer(modifier = Modifier.width(6.dp))
                                Surface(
                                    shape = RoundedCornerShape(6.dp),
                                    color = Color(0xFFEAB308)
                                ) {
                                    Text(
                                        text = "👑 ${settings.tr("hakem")}",
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = Color.Black,
                                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                                    )
                                }
                            }
                        }

                        if (selectedCard != null && viewModel.canUserPlayCard(selectedCard!!)) {
                            Button(
                                onClick = {
                                    val card = selectedCard
                                    if (card != null) {
                                        viewModel.playUserCard(card)
                                        selectedCard = null
                                    }
                                },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = settings.themeType.primaryColor
                                ),
                                contentPadding = PaddingValues(horizontal = 14.dp, vertical = 4.dp),
                                modifier = Modifier
                                    .height(32.dp)
                                    .testTag("play_card_confirm_button")
                            ) {
                                Text(
                                    text = if (isFa) "انداختن کارت" else "Play Card",
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Color.Black
                                )
                            }
                        }
                    }

                    // User Cards Fan / Scroll
                    val scrollState = rememberScrollState()
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .horizontalScroll(scrollState)
                            .padding(vertical = 4.dp),
                        horizontalArrangement = Arrangement.spacedBy((-14).dp),
                        verticalAlignment = Alignment.Bottom
                    ) {
                        viewModel.userHand.forEach { card ->
                            val isSelected = selectedCard == card
                            val isPlayable = viewModel.canUserPlayCard(card)

                            PersianCardView(
                                card = card,
                                width = 56.dp,
                                height = 86.dp,
                                isSelected = isSelected,
                                isEnabled = isPlayable,
                                onClick = {
                                    if (viewModel.currentTurn == PlayerSeat.USER) {
                                        if (isSelected) {
                                            viewModel.playUserCard(card)
                                            selectedCard = null
                                        } else {
                                            selectedCard = card
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
            }

            // HOKM SELECTION DIALOG (POPUP)
            if (viewModel.gameState == HokmGameState.SELECTING_HOKM && viewModel.hakem == PlayerSeat.USER) {
                HokmSuitSelectorDialog(viewModel, settings)
            }

            // ROUND / MATCH FINISHED DIALOG
            if (viewModel.gameState == HokmGameState.ROUND_FINISHED || viewModel.gameState == HokmGameState.MATCH_FINISHED) {
                RoundEndDialog(viewModel, settings)
            }
        }
    }
}

@Composable
private fun ScoreBoardBar(viewModel: HokmViewModel, settings: AppSettings) {
    Surface(
        shape = RoundedCornerShape(14.dp),
        color = settings.themeType.surfaceColor,
        border = BorderStroke(1.dp, Color.White.copy(alpha = 0.1f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 14.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Team Us Score
            Column(horizontalAlignment = Alignment.Start) {
                Text(
                    text = settings.tr("team_us"),
                    fontSize = 11.sp,
                    color = settings.themeType.primaryColor,
                    fontWeight = FontWeight.Bold
                )
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = "Match: ${viewModel.teamUsMatchScore}/7",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Tricks: ${viewModel.teamUsTricks}/7",
                        fontSize = 11.sp,
                        color = Color(0xFFFBBF24)
                    )
                }
            }

            // Trump (Hokm) Suit Badge
            val hSuit = viewModel.hokmSuit
            if (hSuit != null) {
                Surface(
                    shape = RoundedCornerShape(10.dp),
                    color = settings.themeType.backgroundColor,
                    border = BorderStroke(1.dp, hSuit.defaultColor.copy(alpha = 0.6f))
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = hSuit.symbol,
                            fontSize = 18.sp,
                            color = hSuit.defaultColor,
                            fontWeight = FontWeight.Black
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = if (settings.isRtl) hSuit.persianName else hSuit.englishName,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }
                }
            }

            // Team Them Score
            Column(horizontalAlignment = Alignment.End) {
                Text(
                    text = settings.tr("team_them"),
                    fontSize = 11.sp,
                    color = settings.themeType.secondaryColor,
                    fontWeight = FontWeight.Bold
                )
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = "Match: ${viewModel.teamThemMatchScore}/7",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Tricks: ${viewModel.teamThemTricks}/7",
                        fontSize = 11.sp,
                        color = Color(0xFFFBBF24)
                    )
                }
            }
        }
    }
}

@Composable
private fun PlayerSlot(
    name: String,
    seat: PlayerSeat,
    cardsCount: Int,
    isHakem: Boolean,
    isTurn: Boolean,
    accentColor: Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(4.dp)
    ) {
        Box(contentAlignment = Alignment.TopEnd) {
            Surface(
                shape = CircleShape,
                color = if (isTurn) accentColor.copy(alpha = 0.25f) else Color(0xFF1E293B),
                border = BorderStroke(
                    width = if (isTurn) 2.dp else 1.dp,
                    color = if (isTurn) accentColor else Color.Gray.copy(alpha = 0.5f)
                ),
                modifier = Modifier.size(44.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Text(
                        text = when (seat) {
                            PlayerSeat.USER -> "👤"
                            PlayerSeat.PARTNER -> "🤝"
                            PlayerSeat.LEFT -> "🤖"
                            PlayerSeat.RIGHT -> "👾"
                        },
                        fontSize = 20.sp
                    )
                }
            }
            if (isHakem) {
                Surface(
                    shape = CircleShape,
                    color = Color(0xFFEAB308),
                    modifier = Modifier.size(16.dp)
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Text("👑", fontSize = 10.sp)
                    }
                }
            }
        }
        Text(
            text = name,
            fontSize = 10.sp,
            fontWeight = FontWeight.SemiBold,
            color = if (isTurn) accentColor else Color.LightGray,
            modifier = Modifier.padding(top = 2.dp)
        )
        Text(
            text = "$cardsCount 🂠",
            fontSize = 9.sp,
            color = Color.Gray
        )
    }
}

@Composable
private fun CenterTrickTable(viewModel: HokmViewModel, settings: AppSettings) {
    Surface(
        shape = RoundedCornerShape(20.dp),
        color = Color(0xFF0F3B2C).copy(alpha = 0.85f),
        border = BorderStroke(2.dp, Color(0xFFD97706).copy(alpha = 0.6f)),
        modifier = Modifier
            .size(175.dp)
            .padding(4.dp)
    ) {
        Box(
            modifier = Modifier.fillMaxSize().padding(6.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "🎴",
                fontSize = 36.sp,
                color = Color.White.copy(alpha = 0.08f)
            )

            // 4 Played Card positions in current trick
            viewModel.currentTrick.forEach { played ->
                val alignment = when (played.player) {
                    PlayerSeat.USER -> Alignment.BottomCenter
                    PlayerSeat.PARTNER -> Alignment.TopCenter
                    PlayerSeat.LEFT -> Alignment.CenterStart
                    PlayerSeat.RIGHT -> Alignment.CenterEnd
                }

                Box(modifier = Modifier.align(alignment)) {
                    PersianCardView(
                        card = played.card,
                        width = 44.dp,
                        height = 66.dp,
                        isEnabled = false
                    )
                }
            }
        }
    }
}

@Composable
private fun HokmSuitSelectorDialog(viewModel: HokmViewModel, settings: AppSettings) {
    AlertDialog(
        onDismissRequest = { /* Must select */ },
        title = {
            Text(
                text = "👑 ${settings.tr("select_hokm_suit")}",
                fontWeight = FontWeight.Bold,
                fontSize = 16.sp
            )
        },
        text = {
            Column {
                Text(
                    text = if (settings.isRtl)
                        "بر اساس ۵ کارت اولیه خود، خال حکم را مشخص کنید:"
                    else
                        "Based on your first 5 cards, choose the Trump Suit (Hokm):",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.8f)
                )
                Spacer(modifier = Modifier.height(14.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    CardSuit.values().forEach { suit ->
                        OutlinedButton(
                            onClick = { viewModel.selectHokmSuit(suit) },
                            colors = ButtonDefaults.outlinedButtonColors(
                                contentColor = suit.defaultColor
                            ),
                            border = BorderStroke(1.5.dp, suit.defaultColor),
                            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 10.dp)
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text(suit.symbol, fontSize = 24.sp, fontWeight = FontWeight.Black)
                                Text(
                                    text = if (settings.isRtl) suit.persianName else suit.englishName,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }
                }
            }
        },
        confirmButton = {}
    )
}

@Composable
private fun RoundEndDialog(viewModel: HokmViewModel, settings: AppSettings) {
    AlertDialog(
        onDismissRequest = {},
        title = {
            Text(
                text = if (viewModel.gameState == HokmGameState.MATCH_FINISHED) "🏆 پایان مسابقه حکم" else "🎉 پایان دست",
                fontWeight = FontWeight.Bold
            )
        },
        text = {
            Column {
                Text(
                    text = if (settings.isRtl) viewModel.statusMessageFa else viewModel.statusMessageEn,
                    fontSize = 14.sp
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "ما: ${viewModel.teamUsMatchScore}  |  حریفان: ${viewModel.teamThemMatchScore}",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = settings.themeType.primaryColor
                )
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    if (viewModel.gameState == HokmGameState.MATCH_FINISHED) {
                        viewModel.startNewMatch()
                    } else {
                        viewModel.startNewRound()
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = settings.themeType.primaryColor)
            ) {
                Text(
                    text = if (viewModel.gameState == HokmGameState.MATCH_FINISHED) "شروع مسابقه جدید" else "دست بعدی",
                    color = Color.Black,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    )
}
