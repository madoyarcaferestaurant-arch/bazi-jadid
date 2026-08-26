package com.example.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.models.AppSettings
import com.example.ui.components.ChubbyBoyMascot
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(
    settings: AppSettings,
    onNavigateHome: () -> Unit
) {
    val isFa = settings.isRtl

    var startAnimation by remember { mutableStateOf(false) }
    val scaleAnim by animateFloatAsState(
        targetValue = if (startAnimation) 1f else 0.4f,
        animationSpec = tween(700, easing = EaseOutBack),
        label = "scale"
    )
    val alphaAnim by animateFloatAsState(
        targetValue = if (startAnimation) 1f else 0f,
        animationSpec = tween(600),
        label = "alpha"
    )

    LaunchedEffect(Unit) {
        startAnimation = true
        delay(1800)
        onNavigateHome()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        settings.themeType.backgroundColor,
                        settings.themeType.surfaceColor,
                        settings.themeType.backgroundColor
                    )
                )
            )
            .clickable { onNavigateHome() },
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier
                .scale(scaleAnim)
                .alpha(alphaAnim)
                .padding(24.dp)
        ) {
            // Chubby Boy Mascot with animated bouncing
            ChubbyBoyMascot(
                size = 130.dp,
                primaryAccent = settings.themeType.primaryColor,
                isHappy = true
            )

            Spacer(modifier = Modifier.height(20.dp))

            // Studio & App Logo Title
            Text(
                text = "MADOYAR",
                fontSize = 36.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = 4.sp,
                color = settings.themeType.primaryColor
            )

            Text(
                text = if (isFa) "مـادویــار گـیـم هـاب" else "GAME HUB & UNIVERSE",
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = if (isFa) 1.sp else 3.sp,
                color = Color.White.copy(alpha = 0.9f)
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = settings.tr("app_subtitle"),
                fontSize = 12.sp,
                color = Color.LightGray.copy(alpha = 0.8f),
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(30.dp))

            Surface(
                shape = RoundedCornerShape(20.dp),
                color = settings.themeType.primaryColor.copy(alpha = 0.15f),
                border = androidx.compose.foundation.BorderStroke(1.dp, settings.themeType.primaryColor.copy(alpha = 0.5f))
            ) {
                Text(
                    text = if (isFa) "برای ورود سریع لمس کنید" else "Tap anywhere to continue",
                    fontSize = 11.sp,
                    color = settings.themeType.primaryColor,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp)
                )
            }
        }
    }
}
