package com.example.ui.screens

import androidx.compose.animation.core.withInfiniteAnimationFrameMillis
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.models.AppSettings
import kotlin.math.sin
import kotlin.random.Random

enum class GateType { WIDE, NARROW, CRYSTAL }

data class ObstacleGate(
    var y: Float,
    val type: GateType,
    var passed: Boolean = false,
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TwoSparksScreen(
    settings: AppSettings,
    onBack: () -> Unit
) {
    val isFa = settings.isRtl

    var isPlaying by remember { mutableStateOf(true) }
    var isGameOver by remember { mutableStateOf(false) }
    var score by remember { mutableIntStateOf(0) }
    var combo by remember { mutableIntStateOf(0) }
    var maxCombo by remember { mutableIntStateOf(0) }
    var timeLeft by remember { mutableFloatStateOf(25f) }
    var isWideMode by remember { mutableStateOf(false) }

    val gates = remember { mutableStateListOf<ObstacleGate>() }
    var sparkPulsePhase by remember { mutableFloatStateOf(0f) }

    fun restartGame() {
        score = 0
        combo = 0
        maxCombo = 0
        timeLeft = 25f
        isWideMode = false
        isGameOver = false
        isPlaying = true
        gates.clear()
    }

    // Main Game Loop (60 FPS)
    LaunchedEffect(isPlaying, isGameOver) {
        if (!isPlaying || isGameOver) return@LaunchedEffect
        var lastTime = 0L
        var spawnTimer = 0f

        while (isPlaying && !isGameOver) {
            withInfiniteAnimationFrameMillis { frameTime ->
                if (lastTime == 0L) {
                    lastTime = frameTime
                    return@withInfiniteAnimationFrameMillis
                }
                val dt = ((frameTime - lastTime) / 1000f).coerceIn(0.001f, 0.05f)
                lastTime = frameTime

                // Timer Countdown
                timeLeft -= dt
                if (timeLeft <= 0f) {
                    timeLeft = 0f
                    isGameOver = true
                    isPlaying = false
                }

                sparkPulsePhase += dt * 8f

                // Spawn Obstacles
                spawnTimer += dt
                if (spawnTimer >= 0.95f) {
                    spawnTimer = 0f
                    val type = when (Random.nextInt(10)) {
                        in 0..4 -> GateType.WIDE
                        in 5..8 -> GateType.NARROW
                        else -> GateType.CRYSTAL
                    }
                    gates.add(ObstacleGate(y = -40f, type = type))
                }

                // Update Obstacles position & collision
                val speed = 320f + (25f - timeLeft) * 10f
                for (i in gates.indices.reversed()) {
                    val g = gates[i]
                    g.y += speed * dt

                    // Check hit at player line (y ~ 550f relative or 75% height)
                    if (!g.passed && g.y in 520f..570f) {
                        g.passed = true
                        val success = when (g.type) {
                            GateType.WIDE -> isWideMode
                            GateType.NARROW -> !isWideMode
                            GateType.CRYSTAL -> true
                        }

                        if (success) {
                            combo++
                            if (combo > maxCombo) maxCombo = combo
                            val pts = when (g.type) {
                                GateType.CRYSTAL -> 250
                                else -> 100 * (1 + combo / 4)
                            }
                            score += pts
                        } else {
                            combo = 0
                            score = (score - 50).coerceAtLeast(0)
                        }
                    }

                    if (g.y > 900f) {
                        gates.removeAt(i)
                    }
                }
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = settings.tr("two_sparks_title"),
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = settings.tr("back_to_hub")
                        )
                    }
                },
                actions = {
                    IconButton(onClick = { restartGame() }) {
                        Icon(imageVector = Icons.Default.Refresh, contentDescription = "Restart")
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
                .background(settings.themeType.backgroundColor)
                .pointerInput(Unit) {
                    detectTapGestures {
                        if (!isGameOver) {
                            isWideMode = !isWideMode
                        }
                    }
                }
        ) {
            // HIGHWAY ARCADE CANVAS
            Canvas(modifier = Modifier.fillMaxSize()) {
                val w = size.width
                val h = size.height
                val cx = w / 2f
                val playerY = h * 0.76f

                // 1. Cyber Highway Grid Lines
                val laneWidth = w * 0.72f
                val leftEdge = cx - laneWidth / 2f
                val rightEdge = cx + laneWidth / 2f

                drawLine(
                    color = settings.themeType.primaryColor.copy(alpha = 0.35f),
                    start = Offset(leftEdge, 0f),
                    end = Offset(leftEdge, h),
                    strokeWidth = 3f
                )
                drawLine(
                    color = settings.themeType.primaryColor.copy(alpha = 0.35f),
                    start = Offset(rightEdge, 0f),
                    end = Offset(rightEdge, h),
                    strokeWidth = 3f
                )
                drawLine(
                    color = Color.White.copy(alpha = 0.15f),
                    start = Offset(cx, 0f),
                    end = Offset(cx, h),
                    strokeWidth = 1.5f
                )

                // 2. Render Obstacle Gates
                for (g in gates) {
                    val gateY = (g.y / 800f) * h
                    when (g.type) {
                        GateType.WIDE -> {
                            // Wide gate: Opening is in center, blocks sides
                            val blockWidth = laneWidth * 0.22f
                            drawRoundRect(
                                color = Color(0xFFFF007F).copy(alpha = 0.85f),
                                topLeft = Offset(leftEdge, gateY - 14f),
                                size = Size(blockWidth, 28f),
                                cornerRadius = CornerRadius(6f, 6f)
                            )
                            drawRoundRect(
                                color = Color(0xFFFF007F).copy(alpha = 0.85f),
                                topLeft = Offset(rightEdge - blockWidth, gateY - 14f),
                                size = Size(blockWidth, 28f),
                                cornerRadius = CornerRadius(6f, 6f)
                            )
                            // Guide Laser Ring
                            drawLine(
                                color = Color(0xFFFF007F).copy(alpha = 0.5f),
                                start = Offset(leftEdge + blockWidth, gateY),
                                end = Offset(rightEdge - blockWidth, gateY),
                                strokeWidth = 2f
                            )
                        }
                        GateType.NARROW -> {
                            // Narrow gate: Center blocked, pass on sides
                            val blockWidth = laneWidth * 0.38f
                            drawRoundRect(
                                color = Color(0xFF00E5FF).copy(alpha = 0.85f),
                                topLeft = Offset(cx - blockWidth / 2f, gateY - 14f),
                                size = Size(blockWidth, 28f),
                                cornerRadius = CornerRadius(6f, 6f)
                            )
                        }
                        GateType.CRYSTAL -> {
                            // Bonus Crystal
                            drawCircle(
                                color = Color(0xFFFFD700),
                                radius = 14f,
                                center = Offset(cx, gateY)
                            )
                            drawCircle(
                                color = Color.White,
                                radius = 7f,
                                center = Offset(cx, gateY)
                            )
                        }
                    }
                }

                // 3. Render Dual Sparks
                val sparkSpread = if (isWideMode) laneWidth * 0.38f else laneWidth * 0.16f
                val sparkLeftX = cx - sparkSpread
                val sparkRightX = cx + sparkSpread
                val pulse = (sin(sparkPulsePhase.toDouble()).toFloat() * 3f)

                // Laser Beam connecting both sparks
                drawLine(
                    brush = Brush.horizontalGradient(
                        colors = listOf(
                            Color(0xFF00E5FF),
                            Color(0xFFFF007F),
                            Color(0xFF00E5FF)
                        )
                    ),
                    start = Offset(sparkLeftX, playerY),
                    end = Offset(sparkRightX, playerY),
                    strokeWidth = 5f + pulse
                )

                // Left Spark Orb (Cyan)
                drawCircle(
                    color = Color(0xFF00E5FF).copy(alpha = 0.35f),
                    radius = 26f + pulse,
                    center = Offset(sparkLeftX, playerY)
                )
                drawCircle(
                    color = Color(0xFF00E5FF),
                    radius = 16f,
                    center = Offset(sparkLeftX, playerY)
                )
                drawCircle(
                    color = Color.White,
                    radius = 8f,
                    center = Offset(sparkLeftX, playerY)
                )

                // Right Spark Orb (Pink)
                drawCircle(
                    color = Color(0xFFFF007F).copy(alpha = 0.35f),
                    radius = 26f + pulse,
                    center = Offset(sparkRightX, playerY)
                )
                drawCircle(
                    color = Color(0xFFFF007F),
                    radius = 16f,
                    center = Offset(sparkRightX, playerY)
                )
                drawCircle(
                    color = Color.White,
                    radius = 8f,
                    center = Offset(sparkRightX, playerY)
                )
            }

            // HUD OVERLAY (TOP)
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Score
                    Surface(
                        shape = RoundedCornerShape(12.dp),
                        color = settings.themeType.surfaceColor.copy(alpha = 0.85f),
                        border = androidx.compose.foundation.BorderStroke(1.dp, Color.White.copy(alpha = 0.15f))
                    ) {
                        Column(modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp)) {
                            Text(text = settings.tr("score"), fontSize = 11.sp, color = Color.Gray)
                            Text(
                                text = "$score",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Black,
                                color = settings.themeType.primaryColor
                            )
                        }
                    }

                    // Countdown Timer
                    Surface(
                        shape = RoundedCornerShape(14.dp),
                        color = if (timeLeft < 5f) Color(0xFFDC2626) else settings.themeType.primaryColor,
                        modifier = Modifier.padding(horizontal = 4.dp)
                    ) {
                        Text(
                            text = "⏱ ${String.format("%.1f", timeLeft)}s",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Black,
                            color = Color.Black,
                            modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp)
                        )
                    }

                    // Combo
                    Surface(
                        shape = RoundedCornerShape(12.dp),
                        color = settings.themeType.surfaceColor.copy(alpha = 0.85f),
                        border = androidx.compose.foundation.BorderStroke(1.dp, Color.White.copy(alpha = 0.15f))
                    ) {
                        Column(modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp)) {
                            Text(text = settings.tr("combo"), fontSize = 11.sp, color = Color.Gray)
                            Text(
                                text = "x$combo",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Black,
                                color = if (combo > 5) Color(0xFFFFD700) else Color.White
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))

                // Mode Indicator Badge
                Surface(
                    shape = RoundedCornerShape(20.dp),
                    color = if (isWideMode) Color(0xFFFF007F).copy(alpha = 0.25f) else Color(0xFF00E5FF).copy(alpha = 0.25f),
                    border = androidx.compose.foundation.BorderStroke(
                        1.5.dp,
                        if (isWideMode) Color(0xFFFF007F) else Color(0xFF00E5FF)
                    )
                ) {
                    Text(
                        text = if (isWideMode) "⚡ WIDE MODE (فاصله عریض)" else "🔷 NARROW MODE (فاصله باریک)",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = if (isWideMode) Color(0xFFFF007F) else Color(0xFF00E5FF),
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 5.dp)
                    )
                }
            }

            // TAP PROMPT (BOTTOM)
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 24.dp)
            ) {
                Surface(
                    shape = RoundedCornerShape(24.dp),
                    color = Color.Black.copy(alpha = 0.7f),
                    border = androidx.compose.foundation.BorderStroke(1.dp, Color.White.copy(alpha = 0.2f))
                ) {
                    Text(
                        text = "👆 ${settings.tr("shift_pulse")}",
                        color = Color.White,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.padding(horizontal = 20.dp, vertical = 8.dp)
                    )
                }
            }

            // GAME OVER SPRINT DIALOG
            if (isGameOver) {
                val rank = when {
                    score >= 2500 -> "S+ (افسانه‌ای)"
                    score >= 1800 -> "S (فوق‌العاده)"
                    score >= 1100 -> "A (عالی)"
                    else -> "B (خوب)"
                }

                AlertDialog(
                    onDismissRequest = {},
                    title = {
                        Text(
                            text = "⚡ ${settings.tr("game_over")}",
                            fontWeight = FontWeight.Black,
                            fontSize = 20.sp
                        )
                    },
                    text = {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(
                                text = "🏆 $score",
                                fontSize = 34.sp,
                                fontWeight = FontWeight.Black,
                                color = settings.themeType.primaryColor
                            )
                            Text(
                                text = "${settings.tr("final_rank")}: $rank",
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFFFFD700)
                            )
                            Spacer(modifier = Modifier.height(6.dp))
                            Text(
                                text = "حداکثر کمبو: x$maxCombo",
                                fontSize = 13.sp,
                                color = Color.Gray
                            )
                        }
                    },
                    confirmButton = {
                        Button(
                            onClick = { restartGame() },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = settings.themeType.primaryColor
                            )
                        ) {
                            Text(
                                text = "بازی مجدد (Retry)",
                                color = Color.Black,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    },
                    dismissButton = {
                        TextButton(onClick = onBack) {
                            Text(text = settings.tr("back_to_hub"))
                        }
                    }
                )
            }
        }
    }
}
