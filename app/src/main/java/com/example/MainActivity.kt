package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.LayoutDirection
import com.example.models.AppSettings
import com.example.ui.particles.TouchParticleContainer
import com.example.ui.screens.*

enum class AppNavDestination {
    SPLASH,
    HOME,
    HOKM,
    TWO_SPARKS,
    SETTINGS,
    ABOUT
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            val settings = remember { AppSettings() }
            var currentScreen by remember { mutableStateOf(AppNavDestination.SPLASH) }

            val layoutDir = if (settings.isRtl) LayoutDirection.Rtl else LayoutDirection.Ltr

            CompositionLocalProvider(LocalLayoutDirection provides layoutDir) {
                val colorScheme = darkColorScheme(
                    primary = settings.themeType.primaryColor,
                    secondary = settings.themeType.secondaryColor,
                    background = settings.themeType.backgroundColor,
                    surface = settings.themeType.surfaceColor,
                    onPrimary = settings.themeType.backgroundColor,
                    onSecondary = settings.themeType.backgroundColor,
                    onBackground = settings.themeType.onSurfaceColor,
                    onSurface = settings.themeType.onSurfaceColor,
                )

                MaterialTheme(colorScheme = colorScheme) {
                    Surface(
                        modifier = Modifier.fillMaxSize(),
                        color = settings.themeType.backgroundColor
                    ) {
                        TouchParticleContainer(settings = settings) {
                            when (currentScreen) {
                                AppNavDestination.SPLASH -> {
                                    SplashScreen(
                                        settings = settings,
                                        onNavigateHome = { currentScreen = AppNavDestination.HOME }
                                    )
                                }
                                AppNavDestination.HOME -> {
                                    HomeScreen(
                                        settings = settings,
                                        onNavigateHokm = { currentScreen = AppNavDestination.HOKM },
                                        onNavigateTwoSparks = { currentScreen = AppNavDestination.TWO_SPARKS },
                                        onNavigateSettings = { currentScreen = AppNavDestination.SETTINGS },
                                        onNavigateAbout = { currentScreen = AppNavDestination.ABOUT }
                                    )
                                }
                                AppNavDestination.HOKM -> {
                                    BackHandler { currentScreen = AppNavDestination.HOME }
                                    HokmScreen(
                                        settings = settings,
                                        onBack = { currentScreen = AppNavDestination.HOME }
                                    )
                                }
                                AppNavDestination.TWO_SPARKS -> {
                                    BackHandler { currentScreen = AppNavDestination.HOME }
                                    TwoSparksScreen(
                                        settings = settings,
                                        onBack = { currentScreen = AppNavDestination.HOME }
                                    )
                                }
                                AppNavDestination.SETTINGS -> {
                                    BackHandler { currentScreen = AppNavDestination.HOME }
                                    SettingsScreen(
                                        settings = settings,
                                        onBack = { currentScreen = AppNavDestination.HOME }
                                    )
                                }
                                AppNavDestination.ABOUT -> {
                                    BackHandler { currentScreen = AppNavDestination.HOME }
                                    AboutUsScreen(
                                        settings = settings,
                                        onBack = { currentScreen = AppNavDestination.HOME }
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
