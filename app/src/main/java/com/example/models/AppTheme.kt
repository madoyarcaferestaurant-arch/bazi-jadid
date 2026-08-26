package com.example.models

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AcUnit
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Flare
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector

enum class AppThemeType(
    val titleEn: String,
    val titleFa: String,
    val primaryColor: Color,
    val secondaryColor: Color,
    val backgroundColor: Color,
    val surfaceColor: Color,
    val cardColor: Color,
    val onSurfaceColor: Color,
) {
    CYBER_NEON(
        titleEn = "Cyber Neon",
        titleFa = "سایبر نئون",
        primaryColor = Color(0xFF00E5FF),
        secondaryColor = Color(0xFFFF007F),
        backgroundColor = Color(0xFF0D061A),
        surfaceColor = Color(0xFF1B1035),
        cardColor = Color(0xFF241648),
        onSurfaceColor = Color(0xFFF1F5F9),
    ),
    PERSIAN_TURQUOISE(
        titleEn = "Persian Turquoise",
        titleFa = "فیروزه‌ای ایرانی",
        primaryColor = Color(0xFF00B4D8),
        secondaryColor = Color(0xFFFFD166),
        backgroundColor = Color(0xFF071B26),
        surfaceColor = Color(0xFF0C2C3D),
        cardColor = Color(0xFF123E54),
        onSurfaceColor = Color(0xFFF8FAFC),
    ),
    ROYAL_EMERALD(
        titleEn = "Royal Hokm Emerald",
        titleFa = "زمرد سلطنتی حکم",
        primaryColor = Color(0xFF10B981),
        secondaryColor = Color(0xFFF59E0B),
        backgroundColor = Color(0xFF062319),
        surfaceColor = Color(0xFF0B3B2B),
        cardColor = Color(0xFF124F3A),
        onSurfaceColor = Color(0xFFF8FAFC),
    ),
    MIDNIGHT_DARK(
        titleEn = "Midnight Violet",
        titleFa = "بنفش نیمه‌شب",
        primaryColor = Color(0xFFA855F7),
        secondaryColor = Color(0xFFEC4899),
        backgroundColor = Color(0xFF090814),
        surfaceColor = Color(0xFF16122C),
        cardColor = Color(0xFF211B42),
        onSurfaceColor = Color(0xFFF1F5F9),
    ),
}

enum class AppLanguage(val code: String, val displayName: String) {
    PERSIAN("fa", "فارسی"),
    ENGLISH("en", "English"),
}

enum class ParticleEffectType(
    val titleEn: String,
    val titleFa: String,
    val icon: ImageVector,
) {
    FIREWORKS("Fireworks", "آتش‌بازی", Icons.Default.Flare),
    SNOW("Falling Snow", "بارش برف", Icons.Default.AcUnit),
    MIX("Surprise Mix", "ترکیب شگفت‌انگیز", Icons.Default.AutoAwesome),
}
