package com.mebe.mebe_tracker.widget

import android.content.Context
import android.content.SharedPreferences
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.clickable
import androidx.glance.appwidget.*
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider
import android.content.Intent
import android.net.Uri
import java.time.Instant
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit

// ── Palette ──────────────────────────────────────────────────────────────────

private val MebeBackground  = Color(0xFFFFF0F6)
private val MebePrimary     = Color(0xFF9E5E94)
private val MebeText        = Color(0xFF3D1A35)
private val MebeSubtext     = Color(0xFF7A4D6A)
private val MebeBlue        = Color(0xFF6BAEE8)
private val MebeGreen       = Color(0xFF6BC299)
private val MebePink        = Color(0xFFF5ABC2)

private fun cp(c: Color) = ColorProvider(c)

// ── Prefs reader ─────────────────────────────────────────────────────────────

private const val PREFS_NAME = "FlutterSharedPreferences"

data class WidgetData(
    val babyName: String,
    val babyAgeWeeks: Int,
    val lastFeedingTime: Instant?,
    val lastFeedingType: String,
    val nextFeedingTime: Instant?,
    val isSleeping: Boolean,
    val sleepStartTime: Instant?,
    val todayFeedingCount: Int,
    val todaySleepMinutes: Int,
    val todayDiaperCount: Int,
    val todayPumpMl: Double,
    val isPremium: Boolean,
)

private fun SharedPreferences.instant(key: String): Instant? =
    getString(key, null)?.let { runCatching { Instant.parse(it) }.getOrNull() }

private fun loadData(context: Context): WidgetData {
    val p = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    return WidgetData(
        babyName = p.getString("babyName", "MeBé") ?: "MeBé",
        babyAgeWeeks = p.getInt("babyAgeWeeks", 0),
        lastFeedingTime = p.instant("lastFeedingTime"),
        lastFeedingType = p.getString("lastFeedingType", "") ?: "",
        nextFeedingTime = p.instant("nextFeedingTime"),
        isSleeping = p.getBoolean("isSleeping", false),
        sleepStartTime = p.instant("sleepStartTime"),
        todayFeedingCount = p.getInt("todayFeedingCount", 0),
        todaySleepMinutes = p.getInt("todaySleepMinutes", 0),
        todayDiaperCount = p.getInt("todayDiaperCount", 0),
        todayPumpMl = p.getFloat("todayPumpMl", 0f).toDouble(),
        isPremium = p.getBoolean("isPremium", false),
    )
}

// ── Helpers ───────────────────────────────────────────────────────────────────

private fun timeAgo(instant: Instant?): String {
    if (instant == null) return "--"
    val mins = ChronoUnit.MINUTES.between(instant, Instant.now())
    return if (mins < 60) "${mins} phút trước" else "${mins / 60} giờ trước"
}

private fun sleepDuration(start: Instant?): String {
    if (start == null) return ""
    val mins = ChronoUnit.MINUTES.between(start, Instant.now())
    return if (mins < 60) "${mins}p" else "${mins / 60}h${if (mins % 60 > 0) "${mins % 60}p" else ""}"
}

private fun sleepLabel(minutes: Int): String = when {
    minutes == 0 -> "--"
    minutes < 60 -> "${minutes}p"
    else -> "${minutes / 60}h${if (minutes % 60 > 0) "${minutes % 60}p" else ""}"
}

private fun feedingIcon(type: String) = when (type) {
    "breastLeft", "breastRight" -> "🤱"
    "bottle" -> "🍼"
    else -> "🥛"
}

private fun deepLinkAction(host: String) = actionStartActivity(
    Intent(Intent.ACTION_VIEW, Uri.parse("mebe://$host"))
)

// ── Widget ────────────────────────────────────────────────────────────────────

class MeBeWidget : GlanceAppWidget() {

    companion object {
        val smallSize   = DpSize(100.dp, 100.dp)
        val mediumSize  = DpSize(250.dp, 100.dp)
        val largeSize   = DpSize(250.dp, 200.dp)
    }

    override val sizeMode = SizeMode.Responsive(
        setOf(smallSize, mediumSize, largeSize)
    )

    @Composable
    override fun Content() {
        val context = LocalContext.current
        val data = loadData(context)
        val size = LocalSize.current

        GlanceTheme {
            when {
                size.width <= smallSize.width  -> SmallView(data)
                size.width <= mediumSize.width -> MediumView(data)
                else                           -> LargeView(data)
            }
        }
    }
}

// ── Small view ────────────────────────────────────────────────────────────────

@Composable
private fun SmallView(data: WidgetData) {
    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(MebeBackground)
            .clickable(deepLinkAction("home"))
            .padding(10.dp)
    ) {
        if (data.isPremium) {
            Column(modifier = GlanceModifier.fillMaxSize()) {
                Text(
                    data.babyName.ifEmpty { "MeBé" },
                    style = TextStyle(
                        color = cp(MebeText),
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold
                    ),
                    maxLines = 1,
                )
                Spacer(GlanceModifier.height(4.dp))
                if (data.isSleeping) {
                    Text(
                        "🌙 Ngủ ${sleepDuration(data.sleepStartTime)}",
                        style = TextStyle(color = cp(MebeBlue), fontSize = 11.sp),
                    )
                } else {
                    Text(
                        "${feedingIcon(data.lastFeedingType)} ${timeAgo(data.lastFeedingTime)}",
                        style = TextStyle(color = cp(MebeSubtext), fontSize = 11.sp),
                    )
                }
                Spacer(GlanceModifier.defaultWeight())
                Row {
                    StatChip("🤱 ${data.todayFeedingCount}")
                    Spacer(GlanceModifier.width(4.dp))
                    StatChip("🌸 ${data.todayDiaperCount}")
                }
            }
        } else {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text("🐰", style = TextStyle(fontSize = 24.sp))
                Spacer(GlanceModifier.height(4.dp))
                Text(
                    "Nâng cấp\nPremium ✨",
                    style = TextStyle(
                        color = cp(MebeSubtext),
                        fontSize = 10.sp,
                    ),
                )
            }
        }
    }
}

@Composable
private fun StatChip(text: String) {
    Box(
        modifier = GlanceModifier
            .background(MebePrimary.copy(alpha = 0.12f))
            .padding(horizontal = 6.dp, vertical = 2.dp)
            .cornerRadius(12.dp)
    ) {
        Text(text, style = TextStyle(color = cp(MebeText), fontSize = 10.sp))
    }
}

// ── Medium view ───────────────────────────────────────────────────────────────

@Composable
private fun MediumView(data: WidgetData) {
    Row(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(MebeBackground)
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (data.isPremium) {
            // Left: status
            Column(
                modifier = GlanceModifier.defaultWeight(),
            ) {
                Text(
                    data.babyName.ifEmpty { "MeBé" },
                    style = TextStyle(
                        color = cp(MebeText),
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                    ),
                )
                Spacer(GlanceModifier.height(6.dp))
                if (data.isSleeping) {
                    Text(
                        "🌙 Đang ngủ",
                        style = TextStyle(color = cp(MebeBlue), fontSize = 12.sp, fontWeight = FontWeight.Medium),
                        modifier = GlanceModifier.clickable(deepLinkAction("sleep")),
                    )
                    Text(
                        sleepDuration(data.sleepStartTime),
                        style = TextStyle(color = cp(MebeSubtext), fontSize = 11.sp),
                    )
                } else {
                    Text(
                        "${feedingIcon(data.lastFeedingType)} ${timeAgo(data.lastFeedingTime)}",
                        style = TextStyle(color = cp(MebeText), fontSize = 12.sp),
                        modifier = GlanceModifier.clickable(deepLinkAction("feeding")),
                    )
                }
            }
            // Right: stats
            Column(
                modifier = GlanceModifier.defaultWeight(),
                horizontalAlignment = Alignment.End,
            ) {
                MiniStatRow("🤱", "${data.todayFeedingCount} cữ", "feeding")
                Spacer(GlanceModifier.height(4.dp))
                MiniStatRow("🌙", sleepLabel(data.todaySleepMinutes), "sleep")
                Spacer(GlanceModifier.height(4.dp))
                MiniStatRow("🌸", "${data.todayDiaperCount} tã", "diaper")
            }
        } else {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("🐰", style = TextStyle(fontSize = 32.sp))
                Spacer(GlanceModifier.width(12.dp))
                Column {
                    Text(
                        data.babyName.ifEmpty { "MeBé" },
                        style = TextStyle(color = cp(MebeText), fontSize = 14.sp, fontWeight = FontWeight.Bold),
                    )
                    Text(
                        "Nâng cấp Premium để xem chi tiết ✨",
                        style = TextStyle(color = cp(MebeSubtext), fontSize = 11.sp),
                    )
                }
            }
        }
    }
}

@Composable
private fun MiniStatRow(icon: String, label: String, deepLinkHost: String) {
    Row(
        modifier = GlanceModifier.clickable(deepLinkAction(deepLinkHost)),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(icon, style = TextStyle(fontSize = 12.sp))
        Spacer(GlanceModifier.width(4.dp))
        Text(label, style = TextStyle(color = cp(MebeText), fontSize = 12.sp))
    }
}

// ── Large view ────────────────────────────────────────────────────────────────

@Composable
private fun LargeView(data: WidgetData) {
    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(MebeBackground)
            .padding(14.dp),
    ) {
        if (data.isPremium) {
            // Header
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    "🐰 ${data.babyName.ifEmpty { "MeBé" }}",
                    style = TextStyle(color = cp(MebeText), fontSize = 15.sp, fontWeight = FontWeight.Bold),
                    modifier = GlanceModifier.defaultWeight(),
                )
                Text(
                    "${data.babyAgeWeeks} tuần",
                    style = TextStyle(color = cp(MebeSubtext), fontSize = 11.sp),
                )
            }
            Spacer(GlanceModifier.height(10.dp))

            // Status
            if (data.isSleeping) {
                Text(
                    "🌙 Đang ngủ  ${sleepDuration(data.sleepStartTime)}",
                    style = TextStyle(color = cp(MebeBlue), fontSize = 13.sp, fontWeight = FontWeight.Medium),
                    modifier = GlanceModifier.clickable(deepLinkAction("sleep")),
                )
            } else {
                Text(
                    "${feedingIcon(data.lastFeedingType)} Bú ${timeAgo(data.lastFeedingTime)}",
                    style = TextStyle(color = cp(MebeText), fontSize = 13.sp),
                    modifier = GlanceModifier.clickable(deepLinkAction("feeding")),
                )
                data.nextFeedingTime?.let {
                    Text(
                        "⏰ Bú tiếp: ${timeAgo(it)}",
                        style = TextStyle(color = cp(MebeSubtext), fontSize = 11.sp),
                    )
                }
            }
            Spacer(GlanceModifier.height(10.dp))

            // Stats grid (2 columns)
            Row(modifier = GlanceModifier.fillMaxWidth()) {
                LargeStatCard("🤱", "Bú", "${data.todayFeedingCount} cữ", MebePink, "feeding",
                    GlanceModifier.defaultWeight())
                Spacer(GlanceModifier.width(8.dp))
                LargeStatCard("🌙", "Ngủ", sleepLabel(data.todaySleepMinutes), MebeBlue, "sleep",
                    GlanceModifier.defaultWeight())
            }
            Spacer(GlanceModifier.height(8.dp))
            Row(modifier = GlanceModifier.fillMaxWidth()) {
                LargeStatCard("🌸", "Thay tã", "${data.todayDiaperCount} lần", MebeGreen, "diaper",
                    GlanceModifier.defaultWeight())
                Spacer(GlanceModifier.width(8.dp))
                LargeStatCard("🥛", "Hút sữa",
                    if (data.todayPumpMl > 0) "${data.todayPumpMl.toInt()}ml" else "--",
                    MebePrimary, "pumping", GlanceModifier.defaultWeight())
            }
        } else {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text("🐰", style = TextStyle(fontSize = 40.sp))
                Spacer(GlanceModifier.height(8.dp))
                Text(
                    data.babyName.ifEmpty { "MeBé" },
                    style = TextStyle(color = cp(MebeText), fontSize = 16.sp, fontWeight = FontWeight.Bold),
                )
                Spacer(GlanceModifier.height(6.dp))
                Text(
                    "Nâng cấp lên Premium để theo dõi\nbé yêu từ màn hình chính ✨",
                    style = TextStyle(color = cp(MebeSubtext), fontSize = 12.sp),
                )
            }
        }
    }
}

@Composable
private fun LargeStatCard(
    icon: String,
    label: String,
    value: String,
    accentColor: Color,
    deepLinkHost: String,
    modifier: GlanceModifier,
) {
    Box(
        modifier = modifier
            .background(accentColor.copy(alpha = 0.12f))
            .cornerRadius(10.dp)
            .padding(10.dp)
            .clickable(deepLinkAction(deepLinkHost))
    ) {
        Column {
            Text(icon, style = TextStyle(fontSize = 16.sp))
            Spacer(GlanceModifier.height(2.dp))
            Text(label, style = TextStyle(color = cp(MebeSubtext), fontSize = 10.sp))
            Text(value, style = TextStyle(color = cp(accentColor), fontSize = 14.sp, fontWeight = FontWeight.Bold))
        }
    }
}

// ── Widget receiver ───────────────────────────────────────────────────────────

class MeBeWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = MeBeWidget()
}
