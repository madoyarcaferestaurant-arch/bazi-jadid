package com.example.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.models.AppLanguage
import com.example.models.AppSettings
import com.example.models.AppThemeType
import com.example.models.ParticleEffectType

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    settings: AppSettings,
    onBack: () -> Unit
) {
    val isFa = settings.isRtl

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = settings.tr("settings"),
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp
                    )
                },
                navigationIcon = {
                    IconButton(
                        onClick = onBack,
                        modifier = Modifier.testTag("settings_back_button")
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = settings.tr("back_to_hub")
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
            verticalArrangement = Arrangement.spacedBy(16.dp),
            contentPadding = PaddingValues(top = 16.dp, bottom = 32.dp)
        ) {
            // 1. THEME SELECTOR
            item {
                Text(
                    text = "🎨 ${settings.tr("theme_selector")}",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Spacer(modifier = Modifier.height(8.dp))

                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    AppThemeType.values().forEach { theme ->
                        val isSelected = settings.themeType == theme
                        Card(
                            shape = RoundedCornerShape(14.dp),
                            colors = CardDefaults.cardColors(containerColor = theme.surfaceColor),
                            border = BorderStroke(
                                width = if (isSelected) 2.dp else 1.dp,
                                color = if (isSelected) theme.primaryColor else Color.White.copy(alpha = 0.1f)
                            ),
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { settings.themeType = theme }
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(14.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    // Color swatch dots
                                    Box(
                                        modifier = Modifier
                                            .size(22.dp)
                                            .clip(CircleShape)
                                            .background(theme.primaryColor)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Box(
                                        modifier = Modifier
                                            .size(22.dp)
                                            .clip(CircleShape)
                                            .background(theme.secondaryColor)
                                    )
                                    Spacer(modifier = Modifier.width(12.dp))
                                    Text(
                                        text = if (isFa) theme.titleFa else theme.titleEn,
                                        fontSize = 14.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = Color.White
                                    )
                                }

                                if (isSelected) {
                                    Icon(
                                        imageVector = Icons.Default.Check,
                                        contentDescription = "Selected",
                                        tint = theme.primaryColor
                                    )
                                }
                            }
                        }
                    }
                }
            }

            // 2. LANGUAGE SELECTOR
            item {
                Text(
                    text = "🌐 ${settings.tr("language_selector")}",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Spacer(modifier = Modifier.height(8.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    AppLanguage.values().forEach { lang ->
                        val isSelected = settings.language == lang
                        Button(
                            onClick = { settings.language = lang },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = if (isSelected) settings.themeType.primaryColor else settings.themeType.surfaceColor
                            ),
                            shape = RoundedCornerShape(12.dp),
                            border = BorderStroke(
                                1.dp,
                                if (isSelected) settings.themeType.primaryColor else Color.White.copy(alpha = 0.15f)
                            ),
                            modifier = Modifier.weight(1f)
                        ) {
                            Text(
                                text = lang.displayName,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (isSelected) Color.Black else Color.White
                            )
                        }
                    }
                }
            }

            // 3. TOUCH ME PARTICLES
            item {
                Text(
                    text = "✨ ${settings.tr("touch_me")}",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Spacer(modifier = Modifier.height(8.dp))

                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = settings.themeType.surfaceColor),
                    border = BorderStroke(1.dp, Color.White.copy(alpha = 0.1f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(14.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = settings.tr("touch_me"),
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Color.White
                                )
                                Text(
                                    text = settings.tr("touch_me_sub"),
                                    fontSize = 11.sp,
                                    color = Color.Gray
                                )
                            }
                            Switch(
                                checked = settings.touchMeParticles,
                                onCheckedChange = { settings.touchMeParticles = it },
                                colors = SwitchDefaults.colors(
                                    checkedThumbColor = Color.Black,
                                    checkedTrackColor = settings.themeType.primaryColor
                                )
                            )
                        }

                        if (settings.touchMeParticles) {
                            Spacer(modifier = Modifier.height(14.dp))
                            Text(
                                text = settings.tr("particle_style"),
                                fontSize = 12.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = settings.themeType.primaryColor
                            )
                            Spacer(modifier = Modifier.height(8.dp))

                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                ParticleEffectType.values().forEach { pType ->
                                    val isSelected = settings.particleType == pType
                                    Surface(
                                        shape = RoundedCornerShape(10.dp),
                                        color = if (isSelected) settings.themeType.primaryColor.copy(alpha = 0.2f) else settings.themeType.backgroundColor,
                                        border = BorderStroke(
                                            1.dp,
                                            if (isSelected) settings.themeType.primaryColor else Color.White.copy(alpha = 0.1f)
                                        ),
                                        modifier = Modifier
                                            .weight(1f)
                                            .clickable { settings.particleType = pType }
                                    ) {
                                        Column(
                                            modifier = Modifier.padding(8.dp),
                                            horizontalAlignment = Alignment.CenterHorizontally
                                        ) {
                                            Icon(
                                                imageVector = pType.icon,
                                                contentDescription = null,
                                                tint = if (isSelected) settings.themeType.primaryColor else Color.Gray,
                                                modifier = Modifier.size(20.dp)
                                            )
                                            Spacer(modifier = Modifier.height(4.dp))
                                            Text(
                                                text = if (isFa) pType.titleFa else pType.titleEn,
                                                fontSize = 10.sp,
                                                fontWeight = FontWeight.Bold,
                                                color = if (isSelected) Color.White else Color.Gray
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 4. SOUND TOGGLE
            item {
                Text(
                    text = "🔊 ${settings.tr("sound_effects")}",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Spacer(modifier = Modifier.height(8.dp))

                Card(
                    shape = RoundedCornerShape(14.dp),
                    colors = CardDefaults.cardColors(containerColor = settings.themeType.surfaceColor),
                    border = BorderStroke(1.dp, Color.White.copy(alpha = 0.1f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(14.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = settings.tr("sound_effects"),
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                        Switch(
                            checked = settings.soundEnabled,
                            onCheckedChange = { settings.soundEnabled = it },
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = Color.Black,
                                checkedTrackColor = settings.themeType.primaryColor
                            )
                        )
                    }
                }
            }
        }
    }
}
