package com.example.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.models.AppSettings
import com.example.models.AppThemeType
import com.example.ui.components.ChubbyBoyMascot

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    settings: AppSettings,
    onNavigateHokm: () -> Unit,
    onNavigateTwoSparks: () -> Unit,
    onNavigateSettings: () -> Unit,
    onNavigateAbout: () -> Unit,
) {
    val isFa = settings.isRtl

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        ChubbyBoyMascot(size = 36.dp, primaryAccent = settings.themeType.primaryColor)
                        Spacer(modifier = Modifier.width(10.dp))
                        Column {
                            Text(
                                text = "MADOYAR",
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Black,
                                letterSpacing = 2.sp,
                                color = settings.themeType.primaryColor
                            )
                            Text(
                                text = settings.tr("app_title"),
                                fontSize = 11.sp,
                                color = Color.White.copy(alpha = 0.8f)
                            )
                        }
                    }
                },
                actions = {
                    IconButton(
                        onClick = onNavigateAbout,
                        modifier = Modifier.testTag("home_about_button")
                    ) {
                        Icon(
                            imageVector = Icons.Default.Info,
                            contentDescription = settings.tr("about_us"),
                            tint = Color.White.copy(alpha = 0.85f)
                        )
                    }
                    IconButton(
                        onClick = onNavigateSettings,
                        modifier = Modifier.testTag("home_settings_button")
                    ) {
                        Icon(
                            imageVector = Icons.Default.Settings,
                            contentDescription = settings.tr("settings"),
                            tint = Color.White.copy(alpha = 0.85f)
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
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
            contentPadding = PaddingValues(top = 12.dp, bottom = 28.dp)
        ) {
            // 1. HERO MASCOT BANNER
            item {
                HeroBanner(settings)
            }

            // 2. QUICK SHORTCUTS STRIP (Touch Me particles & Theme quick preview)
            item {
                QuickControlsBar(settings)
            }

            // 3. SECTION HEADER: FEATURED GAMES
            item {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(top = 4.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "🎮 ${settings.tr("games")}",
                        fontSize = 17.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Text(
                        text = "2 Games",
                        fontSize = 11.sp,
                        color = settings.themeType.primaryColor
                    )
                }
            }

            // 4. GAME 1: HOKM (PERSIAN 4P CARD GAME)
            item {
                GameCard(
                    title = settings.tr("hokm_title"),
                    badge = if (isFa) "اصیل و استراتژیک" else "ROYAL STRATEGY",
                    description = settings.tr("hokm_desc"),
                    icon = "👑🎴",
                    gradientColors = listOf(Color(0xFF0F4C3A), Color(0xFF062319)),
                    accentColor = Color(0xFFF59E0B),
                    tag = "hokm_game_card",
                    onClick = onNavigateHokm
                )
            }

            // 5. GAME 2: TWO SPARKS (PULSE MODE REFLEX RUNNER)
            item {
                GameCard(
                    title = settings.tr("two_sparks_title"),
                    badge = if (isFa) "سرعتی و هیجانی" else "25s REFLEX SPRINT",
                    description = settings.tr("two_sparks_desc"),
                    icon = "⚡✨",
                    gradientColors = listOf(Color(0xFF2E1065), Color(0xFF0F0624)),
                    accentColor = Color(0xFF00E5FF),
                    tag = "two_sparks_game_card",
                    onClick = onNavigateTwoSparks
                )
            }

            // 6. TOUCH ME PARTICLES CALLOUT BANNER
            item {
                TouchMeFeatureCard(settings, onNavigateSettings)
            }
        }
    }
}

@Composable
private fun HeroBanner(settings: AppSettings) {
    Card(
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = settings.themeType.surfaceColor),
        border = BorderStroke(1.dp, settings.themeType.primaryColor.copy(alpha = 0.35f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Surface(
                    shape = RoundedCornerShape(8.dp),
                    color = settings.themeType.primaryColor.copy(alpha = 0.2f)
                ) {
                    Text(
                        text = "MAD O YAR STUDIOS",
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        color = settings.themeType.primaryColor,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp)
                    )
                }
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = if (settings.isRtl) "به دنیای مادویار خوش آمدید!" else "Welcome to Madoyar Hub!",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = settings.tr("app_subtitle"),
                    fontSize = 11.sp,
                    color = Color.LightGray.copy(alpha = 0.8f),
                    lineHeight = 15.sp
                )
            }
            Spacer(modifier = Modifier.width(12.dp))
            ChubbyBoyMascot(
                size = 85.dp,
                primaryAccent = settings.themeType.primaryColor,
                isHappy = true
            )
        }
    }
}

@Composable
private fun QuickControlsBar(settings: AppSettings) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Touch Me Toggle Chip
        Surface(
            shape = RoundedCornerShape(12.dp),
            color = if (settings.touchMeParticles) settings.themeType.primaryColor.copy(alpha = 0.2f) else settings.themeType.surfaceColor,
            border = BorderStroke(1.dp, if (settings.touchMeParticles) settings.themeType.primaryColor else Color.White.copy(alpha = 0.1f)),
            modifier = Modifier
                .weight(1f)
                .clickable { settings.touchMeParticles = !settings.touchMeParticles }
        ) {
            Row(
                modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                Icon(
                    imageVector = Icons.Default.AutoAwesome,
                    contentDescription = null,
                    tint = if (settings.touchMeParticles) settings.themeType.primaryColor else Color.Gray,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = if (settings.touchMeParticles) "Particles ON" else "Particles OFF",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = if (settings.touchMeParticles) settings.themeType.primaryColor else Color.Gray
                )
            }
        }

        // Theme Cycle Chip
        Surface(
            shape = RoundedCornerShape(12.dp),
            color = settings.themeType.surfaceColor,
            border = BorderStroke(1.dp, Color.White.copy(alpha = 0.1f)),
            modifier = Modifier
                .weight(1f)
                .clickable {
                    val allThemes = AppThemeType.values()
                    val nextIdx = (settings.themeType.ordinal + 1) % allThemes.size
                    settings.themeType = allThemes[nextIdx]
                }
        ) {
            Row(
                modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Palette,
                    contentDescription = null,
                    tint = settings.themeType.secondaryColor,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = if (settings.isRtl) settings.themeType.titleFa else settings.themeType.titleEn,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }
        }
    }
}

@Composable
private fun GameCard(
    title: String,
    badge: String,
    description: String,
    icon: String,
    gradientColors: List<Color>,
    accentColor: Color,
    tag: String,
    onClick: () -> Unit,
) {
    Card(
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = Color.Transparent),
        border = BorderStroke(1.dp, accentColor.copy(alpha = 0.4f)),
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .testTag(tag)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(Brush.horizontalGradient(gradientColors))
                .padding(16.dp)
        ) {
            Column {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Surface(
                        shape = RoundedCornerShape(8.dp),
                        color = accentColor.copy(alpha = 0.2f)
                    ) {
                        Text(
                            text = badge,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            color = accentColor,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                        )
                    }
                    Text(text = icon, fontSize = 24.sp)
                }

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = title,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.White
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = description,
                    fontSize = 11.sp,
                    color = Color.LightGray.copy(alpha = 0.85f),
                    lineHeight = 16.sp
                )

                Spacer(modifier = Modifier.height(14.dp))

                Button(
                    onClick = onClick,
                    colors = ButtonDefaults.buttonColors(containerColor = accentColor),
                    shape = RoundedCornerShape(10.dp),
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 6.dp),
                    modifier = Modifier.height(34.dp)
                ) {
                    Text(
                        text = "▶ شروع بازی (Play)",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.Black
                    )
                }
            }
        }
    }
}

@Composable
private fun TouchMeFeatureCard(settings: AppSettings, onNavigateSettings: () -> Unit) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = settings.themeType.surfaceColor.copy(alpha = 0.6f)),
        border = BorderStroke(1.dp, Color.White.copy(alpha = 0.1f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.weight(1f)) {
                Surface(
                    shape = CircleShape,
                    color = settings.themeType.primaryColor.copy(alpha = 0.2f),
                    modifier = Modifier.size(38.dp)
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(
                            imageVector = settings.particleType.icon,
                            contentDescription = null,
                            tint = settings.themeType.primaryColor,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
                Spacer(modifier = Modifier.width(12.dp))
                Column {
                    Text(
                        text = settings.tr("touch_me"),
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Text(
                        text = settings.tr("tap_test_prompt"),
                        fontSize = 10.sp,
                        color = Color.Gray
                    )
                }
            }

            TextButton(onClick = onNavigateSettings) {
                Text(
                    text = if (settings.isRtl) "تغییر حالت" else "Customize",
                    fontSize = 11.sp,
                    color = settings.themeType.primaryColor
                )
            }
        }
    }
}
