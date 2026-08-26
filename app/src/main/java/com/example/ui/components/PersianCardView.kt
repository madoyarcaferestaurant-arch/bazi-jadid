package com.example.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.models.CardRank
import com.example.models.PlayingCard

@Composable
fun PersianCardView(
    card: PlayingCard,
    modifier: Modifier = Modifier,
    width: Dp = 60.dp,
    height: Dp = 90.dp,
    isSelected: Boolean = false,
    isEnabled: Boolean = true,
    onClick: (() -> Unit)? = null,
) {
    val offsetY by animateFloatAsState(
        targetValue = if (isSelected) -14f else 0f,
        animationSpec = tween(150),
        label = "lift"
    )

    val suitColor = if (card.suit.isRed) Color(0xFFDC2626) else Color(0xFF1E293B)
    val goldBorder = Color(0xFFEAB308)

    Card(
        modifier = modifier
            .width(width)
            .height(height)
            .offset(y = offsetY.dp)
            .clickable(enabled = isEnabled && onClick != null) { onClick?.invoke() },
        shape = RoundedCornerShape(8.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color(0xFFFFFDF8)
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = if (isSelected) 8.dp else 3.dp
        ),
        border = BorderStroke(
            width = if (isSelected) 2.dp else 1.dp,
            color = if (isSelected) Color(0xFF00E5FF) else goldBorder.copy(alpha = 0.7f)
        )
    ) {
        Box(modifier = Modifier.fillMaxSize().padding(4.dp)) {
            // Intricate Persian Toranj pattern in background
            Canvas(modifier = Modifier.fillMaxSize()) {
                val w = size.width
                val h = size.height
                val cx = w / 2f
                val cy = h / 2f

                // Center diamond toranj watermark
                val path = Path().apply {
                    moveTo(cx, cy - h * 0.22f)
                    lineTo(cx + w * 0.26f, cy)
                    lineTo(cx, cy + h * 0.22f)
                    lineTo(cx - w * 0.26f, cy)
                    close()
                }
                drawPath(path, color = goldBorder.copy(alpha = 0.12f), style = Fill)
                drawPath(path, color = goldBorder.copy(alpha = 0.35f), style = Stroke(width = 1.2f))
            }

            // Top-Left Index
            Column(
                modifier = Modifier.align(Alignment.TopStart),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = card.rank.symbol,
                    fontSize = if (width < 50.dp) 11.sp else 13.sp,
                    fontWeight = FontWeight.Black,
                    color = suitColor,
                    lineHeight = 13.sp
                )
                Text(
                    text = card.suit.symbol,
                    fontSize = if (width < 50.dp) 10.sp else 12.sp,
                    color = suitColor,
                    lineHeight = 12.sp
                )
            }

            // Center Royal Character / Pip
            Box(
                modifier = Modifier.align(Alignment.Center),
                contentAlignment = Alignment.Center
            ) {
                if (card.rank == CardRank.KING || card.rank == CardRank.QUEEN || card.rank == CardRank.JACK) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = when (card.rank) {
                                CardRank.KING -> "👑"
                                CardRank.QUEEN -> "👸"
                                CardRank.JACK -> "💂"
                                else -> ""
                            },
                            fontSize = if (width < 50.dp) 14.sp else 18.sp
                        )
                        Text(
                            text = card.rank.symbol,
                            fontSize = if (width < 50.dp) 10.sp else 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = suitColor
                        )
                    }
                } else if (card.rank == CardRank.ACE) {
                    Text(
                        text = card.suit.symbol,
                        fontSize = if (width < 50.dp) 22.sp else 30.sp,
                        color = suitColor
                    )
                } else {
                    Text(
                        text = card.suit.symbol,
                        fontSize = if (width < 50.dp) 16.sp else 22.sp,
                        color = suitColor
                    )
                }
            }

            // Bottom-Right Inverted Index
            Column(
                modifier = Modifier.align(Alignment.BottomEnd),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = card.suit.symbol,
                    fontSize = if (width < 50.dp) 10.sp else 12.sp,
                    color = suitColor,
                    lineHeight = 12.sp
                )
                Text(
                    text = card.rank.symbol,
                    fontSize = if (width < 50.dp) 11.sp else 13.sp,
                    fontWeight = FontWeight.Black,
                    color = suitColor,
                    lineHeight = 13.sp
                )
            }
        }
    }
}
