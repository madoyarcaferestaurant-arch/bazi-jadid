package com.example.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
fun ChubbyBoyMascot(
    modifier: Modifier = Modifier,
    size: Dp = 100.dp,
    primaryAccent: Color = Color(0xFF00E5FF),
    isHappy: Boolean = true,
) {
    val infiniteTransition = rememberInfiniteTransition(label = "mascot")

    // Bobbing bounce
    val bounceY by infiniteTransition.animateFloat(
        initialValue = -4f,
        targetValue = 4f,
        animationSpec = infiniteRepeatable(
            animation = tween(1200, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "bounce"
    )

    // Eye blink trigger
    val blinkProgress by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 0.05f,
        animationSpec = infiniteRepeatable(
            animation = keyframes {
                durationMillis = 3200
                1f at 0
                1f at 2800
                0.05f at 2950
                1f at 3100
            },
            repeatMode = RepeatMode.Restart
        ),
        label = "blink"
    )

    // Breathing pulse
    val breathScale by infiniteTransition.animateFloat(
        initialValue = 0.98f,
        targetValue = 1.02f,
        animationSpec = infiniteRepeatable(
            animation = tween(1600, easing = EaseInOutQuad),
            repeatMode = RepeatMode.Reverse
        ),
        label = "breath"
    )

    Canvas(modifier = modifier.size(size)) {
        val w = this.size.width
        val h = this.size.height
        val cx = w / 2f
        val cy = (h / 2f) + bounceY

        // 1. Soft Outer Aura Glow
        drawCircle(
            color = primaryAccent.copy(alpha = 0.2f),
            radius = (w * 0.44f) * breathScale,
            center = Offset(cx, cy)
        )

        // 2. Cute Chubby Face Body (Warm Ivory/Peach)
        val faceRadius = w * 0.36f
        drawCircle(
            color = Color(0xFFFFF1DB),
            radius = faceRadius,
            center = Offset(cx, cy)
        )
        // Face outline
        drawCircle(
            color = Color(0xFF3B2A1D),
            radius = faceRadius,
            center = Offset(cx, cy),
            style = Stroke(width = 3.5f)
        )

        // 3. Hair Tuft (Playful wood brown curly fringe)
        val hairPath = Path().apply {
            moveTo(cx - faceRadius * 0.65f, cy - faceRadius * 0.4f)
            cubicTo(
                cx - faceRadius * 0.3f, cy - faceRadius * 1.15f,
                cx + faceRadius * 0.1f, cy - faceRadius * 1.1f,
                cx + faceRadius * 0.65f, cy - faceRadius * 0.35f
            )
            cubicTo(
                cx + faceRadius * 0.3f, cy - faceRadius * 0.7f,
                cx - faceRadius * 0.1f, cy - faceRadius * 0.75f,
                cx - faceRadius * 0.65f, cy - faceRadius * 0.4f
            )
            close()
        }
        drawPath(hairPath, color = Color(0xFF5D4037), style = Fill)
        drawPath(hairPath, color = Color(0xFF271C17), style = Stroke(width = 3f))

        // Cute top hair curl
        val curlPath = Path().apply {
            moveTo(cx - 6f, cy - faceRadius * 0.95f)
            quadraticTo(cx + 12f, cy - faceRadius * 1.35f, cx + 22f, cy - faceRadius * 1.15f)
        }
        drawPath(curlPath, color = Color(0xFF5D4037), style = Stroke(width = 4f))

        // 4. Rosy Cheeks
        val cheekRadius = faceRadius * 0.22f
        drawCircle(
            color = Color(0xFFFF8FA3).copy(alpha = 0.65f),
            radius = cheekRadius,
            center = Offset(cx - faceRadius * 0.52f, cy + faceRadius * 0.18f)
        )
        drawCircle(
            color = Color(0xFFFF8FA3).copy(alpha = 0.65f),
            radius = cheekRadius,
            center = Offset(cx + faceRadius * 0.52f, cy + faceRadius * 0.18f)
        )

        // 5. Big Expressive Anime Eyes
        val eyeW = faceRadius * 0.2f
        val eyeH = (faceRadius * 0.26f) * blinkProgress
        val eyeY = cy - faceRadius * 0.05f

        // Left Eye
        drawRoundRect(
            color = Color(0xFF261C14),
            topLeft = Offset(cx - faceRadius * 0.44f - eyeW / 2, eyeY - eyeH / 2),
            size = Size(eyeW, eyeH.coerceAtLeast(2f)),
            cornerRadius = CornerRadius(eyeW / 2, eyeW / 2)
        )
        if (blinkProgress > 0.5f) {
            // Highlight shine
            drawCircle(
                color = Color.White,
                radius = eyeW * 0.28f,
                center = Offset(cx - faceRadius * 0.46f, eyeY - eyeH * 0.2f)
            )
        }

        // Right Eye
        drawRoundRect(
            color = Color(0xFF261C14),
            topLeft = Offset(cx + faceRadius * 0.44f - eyeW / 2, eyeY - eyeH / 2),
            size = Size(eyeW, eyeH.coerceAtLeast(2f)),
            cornerRadius = CornerRadius(eyeW / 2, eyeW / 2)
        )
        if (blinkProgress > 0.5f) {
            // Highlight shine
            drawCircle(
                color = Color.White,
                radius = eyeW * 0.28f,
                center = Offset(cx + faceRadius * 0.42f, eyeY - eyeH * 0.2f)
            )
        }

        // 6. Cute Smile / W-mouth
        val mouthPath = Path().apply {
            moveTo(cx - faceRadius * 0.22f, cy + faceRadius * 0.22f)
            quadraticTo(cx - faceRadius * 0.08f, cy + faceRadius * 0.42f, cx, cy + faceRadius * 0.26f)
            quadraticTo(cx + faceRadius * 0.08f, cy + faceRadius * 0.42f, cx + faceRadius * 0.22f, cy + faceRadius * 0.22f)
        }
        drawPath(mouthPath, color = Color(0xFF422013), style = Stroke(width = 3.5f))

        // Tiny open mouth tongue when happy
        if (isHappy) {
            val tonguePath = Path().apply {
                moveTo(cx - faceRadius * 0.12f, cy + faceRadius * 0.32f)
                quadraticTo(cx, cy + faceRadius * 0.52f, cx + faceRadius * 0.12f, cy + faceRadius * 0.32f)
                close()
            }
            drawPath(tonguePath, color = Color(0xFFFF5252), style = Fill)
        }
    }
}
