package com.creappi.digiharmony

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Process
import android.provider.Settings
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

/**
 * Canal natif MAISON pour « Mon temps d'ecran ».
 *
 * Lit `UsageStatsManager` (permission PACKAGE_USAGE_STATS) et renvoie des
 * durees agregees. AUCUN reseau, AUCUNE collecte, AUCUN stockage : lecture
 * a la volee, renvoyee telle quelle a Flutter.
 */
class MainActivity : AudioServiceActivity() {
    private val channelName = "digiharmony/screen_time"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsageAccess" -> result.success(hasUsageAccess())
                "openUsageAccessSettings" -> {
                    openUsageAccessSettings()
                    result.success(null)
                }
                "readSummary" -> {
                    try {
                        result.success(readSummary())
                    } catch (e: Exception) {
                        result.error("READ_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    /** Debut du jour (minuit local) pour un decalage de `daysAgo` jours. */
    private fun startOfDay(daysAgo: Int): Calendar {
        val cal = Calendar.getInstance()
        cal.add(Calendar.DAY_OF_YEAR, -daysAgo)
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal
    }

    /** Convertit Calendar.DAY_OF_WEEK (1=dimanche) en 1=lundi..7=dimanche. */
    private fun isoWeekday(cal: Calendar): Int {
        return when (cal.get(Calendar.DAY_OF_WEEK)) {
            Calendar.MONDAY -> 1
            Calendar.TUESDAY -> 2
            Calendar.WEDNESDAY -> 3
            Calendar.THURSDAY -> 4
            Calendar.FRIDAY -> 5
            Calendar.SATURDAY -> 6
            else -> 7
        }
    }

    /** Temps d'ecran (foreground) agrege sur [start, end). */
    private fun foregroundMs(usm: UsageStatsManager, start: Long, end: Long): Long {
        val stats = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            start,
            end,
        ) ?: return 0L
        var total = 0L
        for (s in stats) {
            total += s.totalTimeInForeground
        }
        return total
    }

    private fun readSummary(): Map<String, Any> {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()

        // Aujourd'hui : depuis minuit local jusqu'a maintenant.
        val todayStart = startOfDay(0).timeInMillis
        val todayMs = foregroundMs(usm, todayStart, now)

        // 7 derniers jours glissants (J-6 .. aujourd'hui), ordonnes lun->dim.
        val days = ArrayList<Map<String, Any>>()
        var weekTotal = 0L
        val perWeekday = HashMap<Int, Long>()
        for (offset in 6 downTo 0) {
            val dayStart = startOfDay(offset)
            val startMs = dayStart.timeInMillis
            val endMs = if (offset == 0) now else startOfDay(offset - 1).timeInMillis
            val ms = foregroundMs(usm, startMs, endMs)
            weekTotal += ms
            perWeekday[isoWeekday(dayStart)] = ms
        }

        // Ordonne lundi(1) -> dimanche(7) pour un affichage stable.
        for (weekday in 1..7) {
            val ms = perWeekday[weekday] ?: 0L
            days.add(mapOf("weekday" to weekday, "ms" to ms))
        }

        return mapOf(
            "todayMs" to todayMs,
            "weekTotalMs" to weekTotal,
            "days" to days,
        )
    }
}
