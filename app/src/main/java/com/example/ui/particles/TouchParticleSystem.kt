package com.example.ui.particles

import androidx.compose.animation.core.withInfiniteAnimationFrameMillis
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.input.pointer.pointerInput
import com.example.models.AppSettings
import com.example.models.ParticleEffectType
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin
import kotlin.random.Random

enum class TouchShape {
    SPARK_CIRCLE,
    SPARK_STAR,
    SNOWFLAKE_CLASSIC,
    SNOWFLAKE_CRYSTAL,
    GLOW_ORB
}

class ActiveParticle(
    var position: Offset,
    var velocity: Offset,
    val color: Color,
    val initialSize: Float,
    var size: Float = initialSize,
    var opacity: Float = 1.0f,
    var life: Float = 1.0f,
    val decay: Float,
    val gravity: Float,
    val drag: Float,
    var rotation: Float = 0f,
    val rotationSpeed: Float,
    var wobblePhase: Float = 0f,
    val wobbleSpeed: Float = 0f,
    val wobbleAmp: Float = 0f,
    val shape: TouchShape,
    val isSnow: Boolean,
) {
    val isDead: Boolean get() = life <= 0.01f || opacity <= 0.01f

    fun update(dt: Float) {
        life -= decay * dt
        if (life < 0f) life = 0f
        opacity = life.coerceIn(0f, 1f)

        velocity = Offset(velocity.x * drag, (velocity.y + gravity) * drag)

        if (isSnow) {
            wobblePhase += wobbleSpeed * dt
            val wobbleX = sin(wobblePhase.toDouble()).toFloat() * wobbleAmp
            position += Offset(velocity.x + wobbleX, velocity.y)
        } else {
            position += velocity
        }

        rotation += rotationSpeed * dt
        size = initialSize * if (isSnow) (0.7f + 0.3f * life) else (0.35f + 0.65f * life)
    }
}

class ExpandWaveRing(
    val center: Offset,
    var radius: Float = 6f,
    val maxRadius: Float,
    val color: Color,
    var opacity: Float = 0.85f,
) {
    val isDead: Boolean get() = opacity <= 0.02f || radius >= maxRadius

    fun update(dt: Float) {
        radius += (maxRadius - radius) * 11.0f * dt + 2f
        opacity -= 2.4f * dt
        if (opacity < 0f) opacity = 0f
    }
}

@Composable
fun TouchParticleContainer(
    settings: AppSettings,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    val particles = remember { mutableStateListOf<ActiveParticle>() }
    val rings = remember { mutableStateListOf<ExpandWaveRing>() }

    // Animation Loop
    LaunchedEffect(Unit) {
        var lastTime = 0L
        while (true) {
            withInfiniteAnimationFrameMillis { frameTime ->
                if (lastTime == 0L) {
                    lastTime = frameTime
                    return@withInfiniteAnimationFrameMillis
                }
                val dt = ((frameTime - lastTime) / 1000f).coerceIn(0.001f, 0.05f)
                lastTime = frameTime

                if (particles.isNotEmpty()) {
                    for (i in particles.indices.reversed()) {
                        val p = particles[i]
                        p.update(dt)
                        if (p.isDead) particles.removeAt(i)
                    }
                }

                if (rings.isNotEmpty()) {
                    for (i in rings.indices.reversed()) {
                        val r = rings[i]
                        r.update(dt)
                        if (r.isDead) rings.removeAt(i)
                    }
                }
            }
        }
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .pointerInput(settings.touchMeParticles, settings.particleType) {
                if (!settings.touchMeParticles) return@pointerInput
                awaitEachGesture {
                    val down = awaitFirstDown(requireUnconsumed = false)
                    val pos = down.position
                    val rng = Random

                    val isFireworks = when (settings.particleType) {
                        ParticleEffectType.FIREWORKS -> true
                        ParticleEffectType.SNOW -> false
                        ParticleEffectType.MIX -> rng.nextBoolean()
                    }

                    if (isFireworks) {
                        spawnFireworks(pos, rng, rings, particles)
                    } else {
                        spawnSnow(pos, rng, rings, particles)
                    }
                }
            }
    ) {
        content()

        if (settings.touchMeParticles && (particles.isNotEmpty() || rings.isNotEmpty())) {
            Canvas(modifier = Modifier.fillMaxSize()) {
                // 1. Draw Expanding Rings
                for (r in rings) {
                    drawCircle(
                        color = r.color.copy(alpha = r.opacity.coerceIn(0f, 1f)),
                        radius = r.radius,
                        center = r.center,
                        style = Stroke(width = 3.5f)
                    )
                }

                // 2. Draw Particles
                for (p in particles) {
                    val alpha = p.opacity.coerceIn(0f, 1f)
                    if (alpha <= 0.01f) continue
                    val drawColor = p.color.copy(alpha = alpha)

                    when (p.shape) {
                        TouchShape.SPARK_CIRCLE -> {
                            drawCircle(
                                color = drawColor,
                                radius = p.size,
                                center = p.position
                            )
                        }
                        TouchShape.GLOW_ORB -> {
                            drawCircle(
                                color = drawColor.copy(alpha = alpha * 0.45f),
                                radius = p.size * 1.6f,
                                center = p.position
                            )
                            drawCircle(
                                color = Color.White.copy(alpha = alpha),
                                radius = p.size * 0.6f,
                                center = p.position
                            )
                        }
                        TouchShape.SPARK_STAR -> {
                            drawSparkStar(p.position, p.size * 1.5f, drawColor, p.rotation)
                        }
                        TouchShape.SNOWFLAKE_CLASSIC -> {
                            drawClassicSnowflake(p.position, p.size * 1.4f, drawColor, p.rotation)
                        }
                        TouchShape.SNOWFLAKE_CRYSTAL -> {
                            drawCrystalSnowflake(p.position, p.size * 1.3f, drawColor, p.rotation)
                        }
                    }
                }
            }
        }
    }
}

private val fireworkPalettes = listOf(
    listOf(Color(0xFFFFD700), Color(0xFFFF9100), Color(0xFFFFF9C4), Color(0xFFFF5252)),
    listOf(Color(0xFF00E5FF), Color(0xFFFF007F), Color(0xFF7C4DFF), Color(0xFFFFFFFF)),
    listOf(Color(0xFF00E676), Color(0xFF1DE9B6), Color(0xFF69F0AE), Color(0xFFFFF9C4)),
    listOf(Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFF38BDF8), Color(0xFFFFFFFF)),
)

private val snowPalette = listOf(
    Color(0xFFFFFFFF),
    Color(0xFFE0F2FE),
    Color(0xFFBAE6FD),
    Color(0xFFE0E7FF),
    Color(0xFFFFFBEB)
)

private fun spawnFireworks(
    center: Offset,
    rng: Random,
    rings: MutableList<ExpandWaveRing>,
    particles: MutableList<ActiveParticle>
) {
    val palette = fireworkPalettes[rng.nextInt(fireworkPalettes.size)]
    rings.add(
        ExpandWaveRing(
            center = center,
            maxRadius = 50f + rng.nextFloat() * 30f,
            color = palette.first()
        )
    )

    val count = 24 + rng.nextInt(12)
    for (i in 0 until count) {
        val angle = rng.nextFloat() * (2 * PI.toFloat())
        val speed = 3.5f + rng.nextFloat() * 8.5f
        val vel = Offset(cos(angle.toDouble()).toFloat() * speed, sin(angle.toDouble()).toFloat() * speed)
        val color = palette[rng.nextInt(palette.size)]
        val size = 4f + rng.nextFloat() * 5f
        val shape = when {
            rng.nextFloat() < 0.4f -> TouchShape.SPARK_STAR
            rng.nextFloat() < 0.3f -> TouchShape.GLOW_ORB
            else -> TouchShape.SPARK_CIRCLE
        }

        particles.add(
            ActiveParticle(
                position = center,
                velocity = vel,
                color = color,
                initialSize = size,
                decay = 0.9f + rng.nextFloat() * 0.7f,
                gravity = 0.22f + rng.nextFloat() * 0.15f,
                drag = 0.94f,
                rotation = rng.nextFloat() * 360f,
                rotationSpeed = (rng.nextFloat() - 0.5f) * 16f,
                shape = shape,
                isSnow = false
            )
        )
    }
}

private fun spawnSnow(
    center: Offset,
    rng: Random,
    rings: MutableList<ExpandWaveRing>,
    particles: MutableList<ActiveParticle>
) {
    rings.add(
        ExpandWaveRing(
            center = center,
            maxRadius = 40f + rng.nextFloat() * 20f,
            color = Color(0xFFBAE6FD),
            opacity = 0.6f
        )
    )

    val count = 18 + rng.nextInt(10)
    for (i in 0 until count) {
        val angle = -PI.toFloat() * 0.2f - rng.nextFloat() * PI.toFloat() * 0.6f
        val speed = 1.5f + rng.nextFloat() * 4.5f
        val vel = Offset(
            cos(angle.toDouble()).toFloat() * speed + (rng.nextFloat() - 0.5f) * 1.8f,
            sin(angle.toDouble()).toFloat() * speed
        )
        val color = snowPalette[rng.nextInt(snowPalette.size)]
        val size = 6f + rng.nextFloat() * 6f
        val shape = when {
            rng.nextFloat() < 0.5f -> TouchShape.SNOWFLAKE_CLASSIC
            rng.nextFloat() < 0.35f -> TouchShape.SNOWFLAKE_CRYSTAL
            else -> TouchShape.GLOW_ORB
        }

        particles.add(
            ActiveParticle(
                position = center + Offset((rng.nextFloat() - 0.5f) * 20f, (rng.nextFloat() - 0.5f) * 20f),
                velocity = vel,
                color = color,
                initialSize = size,
                decay = 0.45f + rng.nextFloat() * 0.35f,
                gravity = 0.09f + rng.nextFloat() * 0.08f,
                drag = 0.97f,
                rotation = rng.nextFloat() * 360f,
                rotationSpeed = (rng.nextFloat() - 0.5f) * 6f,
                wobblePhase = rng.nextFloat() * (2 * PI.toFloat()),
                wobbleSpeed = 3f + rng.nextFloat() * 4f,
                wobbleAmp = 1.5f + rng.nextFloat() * 2f,
                shape = shape,
                isSnow = true
            )
        )
    }
}

private fun DrawScope.drawSparkStar(center: Offset, radius: Float, color: Color, angleDegrees: Float) {
    rotate(degrees = angleDegrees, pivot = center) {
        val path = Path()
        val points = 4
        for (i in 0 until points * 2) {
            val r = if (i % 2 == 0) radius else radius * 0.32f
            val a = (i.toFloat() / (points * 2)) * (2 * PI.toFloat())
            val x = center.x + cos(a.toDouble()).toFloat() * r
            val y = center.y + sin(a.toDouble()).toFloat() * r
            if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
        }
        path.close()
        drawPath(path, color = color, style = Fill)
        drawCircle(color = Color.White.copy(alpha = color.alpha), radius = radius * 0.28f, center = center)
    }
}

private fun DrawScope.drawClassicSnowflake(center: Offset, radius: Float, color: Color, angleDegrees: Float) {
    rotate(degrees = angleDegrees, pivot = center) {
        for (i in 0 until 6) {
            val armAngle = (i.toFloat() / 6f) * (2 * PI.toFloat())
            val endX = center.x + cos(armAngle.toDouble()).toFloat() * radius
            val endY = center.y + sin(armAngle.toDouble()).toFloat() * radius
            drawLine(
                color = color,
                start = center,
                end = Offset(endX, endY),
                strokeWidth = 2.4f
            )

            val midX = center.x + cos(armAngle.toDouble()).toFloat() * (radius * 0.55f)
            val midY = center.y + sin(armAngle.toDouble()).toFloat() * (radius * 0.55f)
            val branchLen = radius * 0.35f
            val bAngle1 = armAngle + (PI.toFloat() / 4f)
            val bAngle2 = armAngle - (PI.toFloat() / 4f)

            drawLine(
                color = color,
                start = Offset(midX, midY),
                end = Offset(midX + cos(bAngle1.toDouble()).toFloat() * branchLen, midY + sin(bAngle1.toDouble()).toFloat() * branchLen),
                strokeWidth = 2f
            )
            drawLine(
                color = color,
                start = Offset(midX, midY),
                end = Offset(midX + cos(bAngle2.toDouble()).toFloat() * branchLen, midY + sin(bAngle2.toDouble()).toFloat() * branchLen),
                strokeWidth = 2f
            )
        }
        drawCircle(color = Color.White.copy(alpha = color.alpha), radius = radius * 0.22f, center = center)
    }
}

private fun DrawScope.drawCrystalSnowflake(center: Offset, radius: Float, color: Color, angleDegrees: Float) {
    rotate(degrees = angleDegrees, pivot = center) {
        val path = Path()
        for (i in 0 until 6) {
            val a = (i.toFloat() / 6f) * (2 * PI.toFloat())
            val x = center.x + cos(a.toDouble()).toFloat() * radius
            val y = center.y + sin(a.toDouble()).toFloat() * radius
            if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
        }
        path.close()
        drawPath(path, color = color.copy(alpha = (color.alpha * 0.8f).coerceIn(0f, 1f)), style = Fill)
        drawPath(path, color = Color.White.copy(alpha = color.alpha), style = Stroke(width = 1.8f))
        drawCircle(color = Color.White.copy(alpha = color.alpha), radius = radius * 0.3f, center = center)
    }
}
