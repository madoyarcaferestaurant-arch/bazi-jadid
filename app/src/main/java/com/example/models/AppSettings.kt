package com.example.models

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

class AppSettings {
    var themeType by mutableStateOf(AppThemeType.CYBER_NEON)
    var language by mutableStateOf(AppLanguage.PERSIAN)
    var touchMeParticles by mutableStateOf(true)
    var particleType by mutableStateOf(ParticleEffectType.FIREWORKS)
    var soundEnabled by mutableStateOf(true)
    var musicEnabled by mutableStateOf(true)
    var hapticEnabled by mutableStateOf(true)

    private val translations = mapOf(
        "app_title" to mapOf("en" to "Madoyar Hub", "fa" to "مادویار گیم هاب"),
        "app_subtitle" to mapOf("en" to "Persian Game Universe & Reflex Challenges", "fa" to "جهان بازی‌های اصیل و چالش‌های سرعتی"),
        "home" to mapOf("en" to "Home", "fa" to "خانه"),
        "games" to mapOf("en" to "Featured Games", "fa" to "بازی‌های منتخب"),
        "settings" to mapOf("en" to "Settings", "fa" to "تنظیمات"),
        "about_us" to mapOf("en" to "About Madoyar", "fa" to "درباره مادویار"),
        "play_now" to mapOf("en" to "Play Now", "fa" to "شروع بازی"),
        "hokm_title" to mapOf("en" to "Persian Hokm (4P)", "fa" to "بازی پاسور حکم (۴ نفره)"),
        "hokm_desc" to mapOf("en" to "Classic 4-player Persian card strategy with AI partner & opponents, royal Persian card art, and Hakem suit selection.", "fa" to "بازی اصیل حکم ۴ نفره با هوش مصنوعی هوشمند، طراحی کارت‌های سلطنتی ایرانی، تعیین خال حکم و جدول امتیازات."),
        "two_sparks_title" to mapOf("en" to "Two Sparks (Pulse Mode)", "fa" to "بازی دو اخگر (Two Sparks)"),
        "two_sparks_desc" to mapOf("en" to "Reflex & rhythm sprint! Shift dual laser sparks, dodge neon obstacles, collect energy and score rank S+ in 25 seconds.", "fa" to "چالش سرعتی و رفلکس! هدایت دو گوی لیزری، عبور از موانع ریتمیک نئونی و ثبت رکورد S+ در ۲۵ ثانیه."),
        "touch_me" to mapOf("en" to "Touch Me! (Particle System)", "fa" to "لمسم کن! (افکت ذرات معلق)"),
        "touch_me_sub" to mapOf("en" to "Burst radiant sparks or snowflakes anywhere you touch the screen", "fa" to "نمایش ذرات نورانی یا دانه‌های برف با هر لمس روی صفحه"),
        "particle_style" to mapOf("en" to "Particle Burst Effect", "fa" to "حالت افکت ذرات"),
        "fireworks" to mapOf("en" to "Fireworks", "fa" to "آتش‌بازی"),
        "snow" to mapOf("en" to "Falling Snow", "fa" to "بارش برف"),
        "mix" to mapOf("en" to "Surprise Mix", "fa" to "ترکیب شگفت‌انگیز"),
        "sound_effects" to mapOf("en" to "Sound Effects (SFX)", "fa" to "جلوه‌های صوتی"),
        "theme_selector" to mapOf("en" to "Color Theme", "fa" to "پوسته و تم رنگی"),
        "language_selector" to mapOf("en" to "Language / زبان", "fa" to "زبان برنامه"),
        "tap_test_prompt" to mapOf("en" to "Tap anywhere on screen to experience touch particles!", "fa" to "برای دیدن جادوی ذرات، هر جای صفحه را لمس کنید!"),
        "chubby_boy" to mapOf("en" to "Madoyar Mascot (Chubby Boy)", "fa" to "شخصیت چوبی مادویار (Chubby Boy)"),
        "madoyar_studio" to mapOf("en" to "Madoyar Studio", "fa" to "استودیو مادویار"),
        "version" to mapOf("en" to "Version 2.4.0", "fa" to "نسخه ۲.۴.۰"),
        "hakem" to mapOf("en" to "Hakem (Ruler)", "fa" to "حاکم"),
        "select_hokm_suit" to mapOf("en" to "Select Hokm (Trump Suit)", "fa" to "تعیین خال حکم"),
        "your_turn" to mapOf("en" to "Your Turn - Play a Card", "fa" to "نوبت شماست - یک کارت بازی کنید"),
        "partner" to mapOf("en" to "Partner (AI)", "fa" to "یار شما"),
        "opponent_left" to mapOf("en" to "Rival Left", "fa" to "رقیب چپ"),
        "opponent_right" to mapOf("en" to "Rival Right", "fa" to "رقیب راست"),
        "team_us" to mapOf("en" to "Us (You & Partner)", "fa" to "ما (شما و یار)"),
        "team_them" to mapOf("en" to "Opponents", "fa" to "حریفان"),
        "round" to mapOf("en" to "Round", "fa" to "دست"),
        "match_score" to mapOf("en" to "Match Score", "fa" to "امتیاز مسابقه"),
        "tricks" to mapOf("en" to "Tricks", "fa" to "دست‌های برده"),
        "restart_game" to mapOf("en" to "New Game", "fa" to "دست جدید"),
        "back_to_hub" to mapOf("en" to "Back to Hub", "fa" to "بازگشت به منو"),
        "time_remaining" to mapOf("en" to "Time Left", "fa" to "زمان باقی‌مانده"),
        "score" to mapOf("en" to "Score", "fa" to "امتیاز"),
        "combo" to mapOf("en" to "Combo", "fa" to "کمبو"),
        "shift_pulse" to mapOf("en" to "Tap to Shift Width", "fa" to "لمس برای تغییر فاصله گوی‌ها"),
        "game_over" to mapOf("en" to "Sprint Finished!", "fa" to "پایان راند سرعتی!"),
        "final_rank" to mapOf("en" to "Performance Rank", "fa" to "رتبه عملکرد"),
    )

    fun tr(key: String): String {
        val langCode = language.code
        return translations[key]?.get(langCode) ?: translations[key]?.get("en") ?: key
    }

    val isRtl: Boolean
        get() = language == AppLanguage.PERSIAN
}
