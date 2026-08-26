package com.example.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.models.AppSettings
import com.example.ui.components.ChubbyBoyMascot

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AboutUsScreen(
    settings: AppSettings,
    onBack: () -> Unit
) {
    val isFa = settings.isRtl

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = settings.tr("about_us"),
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp
                    )
                },
                navigationIcon = {
                    IconButton(
                        onClick = onBack,
                        modifier = Modifier.testTag("about_back_button")
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
            verticalArrangement = Arrangement.spacedBy(14.dp),
            contentPadding = PaddingValues(top = 16.dp, bottom = 28.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Mascot & Studio Title
            item {
                ChubbyBoyMascot(
                    size = 110.dp,
                    primaryAccent = settings.themeType.primaryColor,
                    isHappy = true
                )
                Spacer(modifier = Modifier.height(12.dp))
                Text(
                    text = "MADOYAR STUDIOS",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Black,
                    letterSpacing = 2.sp,
                    color = settings.themeType.primaryColor
                )
                Text(
                    text = settings.tr("version"),
                    fontSize = 12.sp,
                    color = Color.Gray
                )
            }

            // Studio Mission Card
            item {
                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = settings.themeType.surfaceColor),
                    border = BorderStroke(1.dp, Color.White.copy(alpha = 0.1f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = if (isFa) "✨ درباره استودیو مادویار" else "✨ About Madoyar Studio",
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = settings.themeType.primaryColor
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = if (isFa)
                                "استودیو مادویار با هدف زنده نگه‌داشتن بازی‌های کهن و اصیل ایرانی و تلفیق آن‌ها با طراحی مدرن نئونی، جلوه‌های بصری تعاملی و گیم‌پلی ریتمیک بنیان‌گذاری شده است. بازی حکم با شبیه‌سازی هوشمند و بازی سرعتی Two Sparks از نخستین تجربیات این مجموعه می‌باشند."
                            else
                                "Madoyar Studios was founded to celebrate heritage card games and reflex-driven experiences, blending royal Persian aesthetic motifs with modern cyber visuals, particle physics, and intelligent AI companion systems.",
                            fontSize = 12.sp,
                            color = Color.LightGray,
                            lineHeight = 18.sp,
                            textAlign = if (isFa) TextAlign.Right else TextAlign.Left
                        )
                    }
                }
            }

            // Chubby Boy Mascot Story
            item {
                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = settings.themeType.surfaceColor),
                    border = BorderStroke(1.dp, Color.White.copy(alpha = 0.1f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = if (isFa) "👦 داستان نماد چوبی (Chubby Boy)" else "👦 The Chubby Boy Mascot",
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = settings.themeType.secondaryColor
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = if (isFa)
                                "«چابی بوی» یا پسربچه چوبی خندان، نماد روحیه بازیگوش، شادی و اصالت است. او در طول بازی همراه شماست و با انیمیشن‌های زنده و واکنش‌های جذاب، فضای پرنشاطی را خلق می‌کند."
                            else
                                "Chubby Boy is our playful mascot crafted with hand-drawn aesthetic contours. He celebrates your trick victories in Hokm and cheers during high-speed Two Sparks combos!",
                            fontSize = 12.sp,
                            color = Color.LightGray,
                            lineHeight = 18.sp,
                            textAlign = if (isFa) TextAlign.Right else TextAlign.Left
                        )
                    }
                }
            }

            // Team Credits
            item {
                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = settings.themeType.surfaceColor),
                    border = BorderStroke(1.dp, Color.White.copy(alpha = 0.1f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = "❤️ Crafts & Development",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = "Designed with Jetpack Compose, Material 3, and Kotlin.",
                            fontSize = 11.sp,
                            color = Color.Gray
                        )
                    }
                }
            }
        }
    }
}
